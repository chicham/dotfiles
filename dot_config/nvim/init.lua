-- Neovim Configuration
-- This file serves as the main entry point for your Neovim setup.
-- It bootstraps the plugin manager, sets fundamental editor options,
-- defines global keybindings, and configures core plugins.
--
-- Fast, focused configuration for efficient editing

-- Options first: the leader keys it sets are what every plugin spec's `keys`
-- table is resolved against, so nothing may load before it.
require("custom.config.options")
require("custom.config.keymaps")
require("custom.config.autocmds")

--------------------------------------------------------------------------------
-- PLUGIN MANAGER BOOTSTRAP (lazy.nvim)
--------------------------------------------------------------------------------
-- lazy.nvim is a fast and powerful plugin manager for Neovim.
-- This section ensures lazy.nvim is installed and available.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- PLUGIN CONFIGURATION
--------------------------------------------------------------------------------
-- This section defines and configures all Neovim plugins using lazy.nvim.
-- Plugins are organized by category for better readability and management.

-- Plugin definitions
-- lazy.nvim's setup function loads and configures all specified plugins. The
-- second argument, at the end of the list, holds lazy's own options.
require("lazy").setup({
  -- Import plugins from custom directory
  { import = "custom.plugins" },
  -- Tree-sitter (main branch). main uses native vim.treesitter with no module
  -- system: highlight / indent / folds are enabled per-filetype via a FileType
  -- autocmd, and incremental selection is a small local reimpl (master's
  -- `incremental_selection` module is gone on main). vim-matchup uses its own
  -- native treesitter integration (g:matchup_treesitter_enabled, default true).
  -- Requires `:TSUpdate` to (re)install parsers into main's install dir
  -- (stdpath('data')/site); main pins specific parser versions.
  {
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
      -- Note: @loop (]l) and @block (]b) moves are intentionally omitted so
      -- unimpaired.nvim keeps loclist (]l) and buffer (]b) navigation. The
      -- @block / @parameter *text objects* (a}/i}, aa/ia) are unaffected.
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
  },

  -- Code formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[C]ode [F]ormat",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable autoformat for languages without a well standardized
        -- coding style. Add filetypes here to opt them out.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and "never" or "fallback",
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  -- Autocompletion
  {
    "saghen/blink.cmp",
    -- Completion cannot be needed before there is an insert or a command line.
    -- Opening a file still loads it earlier than this, via nvim-lspconfig's
    -- dependency on it for get_lsp_capabilities() -- which is what keeps the
    -- capabilities correct -- so this only matters to sessions that never edit.
    event = { "InsertEnter", "CmdlineEnter" },
    version = "1.*",
    dependencies = {
      -- Snippet Engine
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        opts = {},
      },
      "folke/lazydev.nvim",
      "fang2hou/blink-copilot",
      { "saghen/blink.compat", opts = {} },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      enabled = function()
        return not vim.b.blink_disable and not vim.g.blink_disable
      end,
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { "copilot", "lsp", "path", "snippets", "lazydev", "buffer", "orgmode" },
        providers = {
          lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
          orgmode = {
            name = "orgmode",
            module = "blink.compat.source",
          },
        },
      },

      snippets = { preset = "luasnip" },

      fuzzy = { implementation = "lua" },

      signature = { enabled = true },
    },
  },

  -- LSP Configuration
  {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    -- Load on first real buffer instead of at startup: mason, the server
    -- definitions and mason-tool-installer's registry sync all run inside
    -- config(), so deferring to BufReadPre/BufNewFile takes the whole block
    -- off the startup critical path (it still fires before the first file's
    -- FileType, so the server attaches to that buffer as usual).
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim.
      -- mason.nvim + mason-lspconfig moved to the mason-org org
      -- (williamboman/* now just redirects). mason-tool-installer is a
      -- separate project and stays at WhoIsSethDaniel.
      { "mason-org/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      { "j-hui/fidget.nvim", opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      "saghen/blink.cmp",
    },
    config = function()
      --  This function gets run when an LSP attaches to a particular buffer.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- LSP keymaps
          -- Note: gd, gD, gi, gr, gy, gs are handled by fzf-lua for fuzzy finding
          -- Note: <leader>cf (format) is handled by conform.nvim, see its keys spec
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gK", vim.lsp.buf.signature_help, "Signature Documentation")
          map("<space>D", vim.lsp.buf.type_definition, "Type Definition")
          -- Rename and code action live under <leader>r, not <leader>c: the
          -- whole <leader>c space belongs to quickfix-review, whose maps are
          -- global while these are buffer-local, so an LSP buffer would
          -- silently shadow the review commands wherever the two overlap.
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>ra", vim.lsp.buf.code_action, "[R]efactor [A]ction")
          -- Better diagnostic navigation
          vim.keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
          end, { desc = "Previous error" })

          vim.keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
          end, { desc = "Next error" })

          vim.keymap.set("n", "[w", function()
            vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN, float = true })
          end, { desc = "Previous warning" })

          vim.keymap.set("n", "]w", function()
            vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN, float = true })
          end, { desc = "Next warning" })

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Reference highlighting under the cursor is snacks.words' job (see
          -- snacks.lua); it attaches on LspAttach itself and needs nothing here.

          -- Inlay hints toggle keymap
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>ch", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "Code Toggle Inlay [H]ints")
          end
        end,
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Define servers
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        rust_analyzer = {},
        -- basedpyright = {
        -- 	settings = {
        -- 		basedpyright = {
        -- 			disableOrganizeImports = true,
        -- 			analysis = {
        -- 				ignore = { "*" },
        -- 				diagnosticMode = "openFilesOnly",
        -- 				typeCheckingMode = "strict",
        -- 			},
        -- 		},
        -- 	},
        -- },
        ty = {},
        texlab = {
          settings = {
            texlab = {
              build = {
                onSave = false,
              },
              forwardSearch = {
                executable = "skim",
                args = { "-g", "%l", "%f" },
              },
            },
          },
        },
        copilot = {},
      }

      -- Additional LSPs for macOS
      servers.bashls = {}
      servers.clangd = {}
      servers.cssls = {}
      servers.html = {}
      servers.jsonls = {}

      -- Ensure Mason is set up
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      -- Set up servers using mason
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format Lua code
        "shellcheck",
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      -- mason-lspconfig v2 removed the `handlers` field, so per-server settings
      -- and completion capabilities must be registered via the native vim.lsp API
      -- before servers are auto-enabled.
      vim.lsp.config("*", { capabilities = capabilities })
      for server_name, server in pairs(servers) do
        vim.lsp.config(server_name, server)
      end

      -- No `ensure_installed` here: mason-tool-installer above already installs
      -- every server in `servers` (it was drifting from this list anyway).
      -- automatic_enable turns on whatever mason has installed.
      require("mason-lspconfig").setup({
        automatic_enable = true,
      })
    end,
  },
}, {
  performance = {
    rtp = {
      -- Shipped plugins nothing here uses. `matchit` is deliberately absent:
      -- vim-matchup already sets g:loaded_matchit itself, so listing it would
      -- only duplicate that.
      disabled_plugins = {
        "gzip",
        "netrwPlugin", -- oil.nvim is the file explorer, and loads eagerly to be it
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  -- lazy watches the config files and announces edits. This config lives in a
  -- chezmoi source tree and is applied in place, so those notifications fire on
  -- every apply and say nothing useful; the check itself stays on.
  change_detection = { notify = false },
})

-- Treesitter-based "any block" text object (ib / ab) — matches any bracket
-- pair () [] {} as well as any string/quote, including Python's """ """ and
-- f-strings. See lua/custom/anyblock.lua for the rationale.
require("custom.anyblock").setup()

vim.api.nvim_create_user_command("BlinkToggle", function()
  vim.g.blink_disable = not vim.g.blink_disable
  print("blink.cmp " .. (vim.g.blink_disable and "OFF" or "ON"))
end, { desc = "Toggle blink.cmp globally" })

vim.api.nvim_create_user_command("BlinkToggleBuffer", function()
  vim.b.blink_disable = not vim.b.blink_disable
  print("blink.cmp (buffer) " .. (vim.b.blink_disable and "OFF" or "ON"))
end, { desc = "Toggle blink.cmp for current buffer" })

--------------------------------------------------------------------------------
-- CODERPAD PRACTICE MODE
--------------------------------------------------------------------------------
-- Make Neovim feel like the CoderPad interview editor: a bare pad with syntax
-- highlighting and formatting, but none of the automatic "intelligence" that
-- would be unfair to lean on in an interview.
--
-- DISABLED in practice mode (all passive helpers that act on their own):
--   • blink.cmp completion popup  -> no LSP/Copilot/snippet autocomplete, no
--                                    auto signature help (blink owns it)
--   • diagnostics                 -> no error/warning squiggles or inline text
--
-- KEPT (as requested + intentional):
--   • Treesitter highlighting & indentation
--   • treesitter-context sticky function/class header
--   • conform.nvim format-on-save
--   • all motions, text objects, folding, git, etc.
--
-- LSP clients stay ALIVE on purpose: it keeps definition-based folding working
-- and makes the toggle perfectly reversible. Manual lookups (K hover, gK
-- signature, go-to-def, code actions) therefore still work — they never fire on
-- their own, so they don't help unless you deliberately ask. Just don't press
-- them while practising. (Copilot suggestions are fully silenced via blink.)
vim.g.coderpad = false

local function coderpad_apply(on)
  vim.g.coderpad = on
  vim.g.blink_disable = on -- completion + Copilot + auto signature help
  vim.diagnostic.enable(not on) -- error/warning squiggles + tiny-inline-diagnostic

  vim.notify("CoderPad practice mode " .. (on and "ON" or "OFF"), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("CoderPad", function()
  coderpad_apply(not vim.g.coderpad)
end, { desc = "Toggle CoderPad interview-practice mode" })

vim.api.nvim_create_user_command("CoderPadOn", function()
  coderpad_apply(true)
end, { desc = "Enable CoderPad interview-practice mode" })

vim.api.nvim_create_user_command("CoderPadOff", function()
  coderpad_apply(false)
end, { desc = "Disable CoderPad interview-practice mode" })

-- Launch straight into practice mode:  CODERPAD=1 nvim solution.py
if vim.env.CODERPAD ~= nil then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(function()
        coderpad_apply(true)
      end)
    end,
  })
end

-- vim: ts=2 sts=2 sw=2 et
