-- Tree-sitter (main branch). main uses native vim.treesitter with no module
-- system: highlight / indent / folds are enabled per-filetype via a FileType
-- autocmd, and incremental selection is a small local reimpl (master's
-- `incremental_selection` module is gone on main). vim-matchup uses its own
-- native treesitter integration (g:matchup_treesitter_enabled, default true).
-- Requires `:TSUpdate` to (re)install parsers into main's install dir
-- (stdpath('data')/site); main pins specific parser versions.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main does not support lazy-loading
  build = ":TSUpdate",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    "andymass/vim-matchup",
  },
  config = function()
    require("nvim-treesitter").setup()

    -- Parsers to keep installed (org is owned by nvim-orgmode).
    local ensure = {
      "bash",
      "c",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "javascript",
      "typescript",
      "html",
      "css",
      "json",
      "yaml",
      "python",
      "rust",
      "go",
      "markdown",
      "markdown_inline",
      "diff",
      "luadoc",
      "latex",
      "comment",
      "fish",
      "proto",
      "rst",
      "toml",
      "dockerfile",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
    }
    pcall(function()
      require("nvim-treesitter").install(ensure)
    end)

    -- Enable highlight + experimental indent per filetype (no modules on
    -- main). org is handled by nvim-orgmode; ruby keeps vim regex syntax
    -- and its built-in indent. Parsers not yet installed are auto-installed
    -- on first open (restores master's `auto_install`), then highlighting
    -- is enabled once the parser finishes compiling.
    local skip = { org = true, orgagenda = true }
    local available, installed, attempted = {}, {}, {}
    pcall(function()
      for _, l in ipairs(require("nvim-treesitter").get_available()) do
        available[l] = true
      end
      for _, l in ipairs(require("nvim-treesitter").get_installed()) do
        installed[l] = true
      end
    end)
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterEnable", { clear = true }),
      callback = function(args)
        local ft = args.match
        if skip[ft] then
          return
        end
        local buf = args.buf
        local function enable()
          if not pcall(vim.treesitter.start, buf) then
            return false
          end
          if ft == "ruby" then
            vim.bo[buf].syntax = "on"
          else
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
          return true
        end
        if enable() then
          return
        end
        -- No parser yet: auto-install it (only if it's a real parser),
        -- then enable highlighting on this buffer once it's ready.
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if attempted[lang] or installed[lang] or not available[lang] then
          return
        end
        attempted[lang] = true
        require("nvim-treesitter").install({ lang }):await(vim.schedule_wrap(function(err)
          if not err and vim.api.nvim_buf_is_valid(buf) then
            installed[lang] = true
            enable()
          end
        end))
      end,
    })

    -- Minimal incremental selection (replaces the master module):
    -- <C-space> start / expand to parent node, <BS> shrink.
    local stack = {}
    local function select_node(node)
      local sr, sc, er, ec = node:range()
      if ec == 0 then
        er = er - 1
        ec = math.max(#vim.fn.getline(er + 1) - 1, 0)
      else
        ec = ec - 1
      end
      if vim.fn.mode():match("[vV\22]") then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
      end
      vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
      vim.cmd("normal! v")
      vim.api.nvim_win_set_cursor(0, { er + 1, ec })
    end
    local function incr()
      local cur = stack[#stack]
      if vim.fn.mode() ~= "v" or not cur then
        local node = vim.treesitter.get_node()
        if not node then
          return
        end
        stack = { node }
        select_node(node)
        return
      end
      local parent = cur:parent()
      if parent then
        table.insert(stack, parent)
        select_node(parent)
      end
    end
    local function decr()
      if #stack > 1 then
        table.remove(stack)
      end
      if stack[#stack] then
        select_node(stack[#stack])
      end
    end
    vim.keymap.set("n", "<C-space>", incr, { desc = "TS incremental select" })
    vim.keymap.set("x", "<C-space>", incr, { desc = "TS expand selection" })
    vim.keymap.set("x", "<bs>", decr, { desc = "TS shrink selection" })

    -- Text objects live on the textobjects `main` branch now, which is
    -- a standalone plugin (native vim.treesitter) rather than an
    -- nvim-treesitter module, so it is configured here explicitly.
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local map = vim.keymap.set

    -- Selection (operator-pending + visual)
    local selects = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      -- Function CALL on lowercase c (edited more often than class defs).
      -- e.g. dac / cic on foo(bar, baz)
      ["ac"] = "@call.outer",
      ["ic"] = "@call.inner",
      -- Class definition moved to uppercase C.
      ["aC"] = "@class.outer",
      ["iC"] = "@class.inner",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
      -- NB: ai/ii (indentation) are NOT here — indentation is not a
      -- tree-sitter node, so there is no @indent query. They are wired
      -- to nvim-various-textobjs instead (see various-textobjects.lua).
      ["a}"] = "@block.outer",
      ["i}"] = "@block.inner",
    }
    -- Readable which-key labels, e.g. "@function.outer" -> "function (outer)"
    local function obj_desc(query)
      local name, variant = query:match("@(%w+)%.(%w+)")
      return name and (name .. " (" .. variant .. ")") or query
    end
    for lhs, query in pairs(selects) do
      map({ "x", "o" }, lhs, function()
        select.select_textobject(query, "textobjects")
      end, { desc = obj_desc(query) })
    end

    -- Movement (normal + visual + operator-pending).
    -- Note: the @loop move (]l) is intentionally omitted so unimpaired.nvim
    -- keeps loclist navigation, and @block (]b) so vcsigns keeps the diff-base
    -- walk. The @block / @parameter *text objects* (a}/i}, aa/ia) are
    -- unaffected.
    local moves = {
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]c"] = "@class.outer",
        ["]a"] = "@parameter.outer",
        ["]i"] = "@conditional.outer",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]C"] = "@class.outer",
        ["]A"] = "@parameter.outer",
        ["]I"] = "@conditional.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@class.outer",
        ["[a"] = "@parameter.outer",
        ["[i"] = "@conditional.outer",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[C"] = "@class.outer",
        ["[A"] = "@parameter.outer",
        ["[I"] = "@conditional.outer",
      },
    }
    -- Readable which-key labels, e.g. "Next function", "Prev class end"
    local dir_desc = {
      goto_next_start = "Next %s",
      goto_next_end = "Next %s end",
      goto_previous_start = "Prev %s",
      goto_previous_end = "Prev %s end",
    }
    for fn, tbl in pairs(moves) do
      for lhs, query in pairs(tbl) do
        local name = query:match("@(%w+)") or query
        map({ "n", "x", "o" }, lhs, function()
          move[fn](query, "textobjects")
        end, { desc = dir_desc[fn]:format(name) })
      end
    end
  end,
}
