-- Set highlight on search
vim.opt.hlsearch = false

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Save undo history
vim.opt.undofile = true

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"

-- Clipboard
vim.opt.clipboard = "unnamedplus"

vim.opt.termguicolors = true

-- Set completeopt to have a better completion experience
vim.opt.completeopt = "menuone,longest,noinsert"
vim.opt.cursorline = true

vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", trail = "·" }
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = ">>"

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case --follow --hidden --glob '!.git'"
end
vim.diagnostic.config({ virtual_lines = { only_current_line = true }, virtual_text = false })

local bind = vim.keymap.set

bind("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
bind("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--Windows management
bind("n", "<leader><Bar>", "\"<C-W>v<C-W><C-w>zt\"", { expr = true, silent = true })
bind("n", "<leader>-", "\"<C-W>s<C-W><C-W>zt\"", { expr = true, silent = true })
bind("n", "<leader>_", "\"<C-W>s<C-W><C-W>zt\"", { expr = true, silent = true })
bind("n", "<leader><Up>", "<C-w><Up>")
bind("n", "<leader><Down>", "<C-w><Down>")
bind("n", "<leader><Right>", "<C-w><Right>")
bind("n", "<leader><Left>", "<C-w><Left>")
bind("n", "<leader>wc", "<C-w>c")
bind("n", "<leader>w=", "<C-w>=")
bind("n", "<leader>wr", "<C-w>r")
bind("n", "<leader>wo", "<C-w>o")

bind("n", "<leader><leader>", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
-- Macros helpers
bind("n", "Q", "@@")
bind("v", ".", ":normal .")
bind("v", "Q", ":normal @@")

-- Write buffer
bind("n", "W", ":w<cr>", { silent = true })

-- Visual model indent fix
bind("v", "<", "<gv")
bind("v", ">", ">gv")
bind("n", "<leader>pp", ":let @+ = join([expand('%:p'), line('.')], ':')<cr>", { silent = true })

-- fugitive bindings
bind("n", "<leader>gg", ":<C-u>0Git<cr>", { silent = true })
bind("n", "<leader>gw", ":<C-u>Gwrite<cr>")
bind("n", "<leader>gW", ":<C-u>Gwrite!<cr>")
bind("n", "<leader>g+", ":<C-u>Git stash<cr>:e<cr>")
bind("n", "<leader>g-", ":<C-u>Git stash pop<cr>:e<cr>")
bind("n", "<leader>go", ":execute line('.') . ',GBrowse'<cr>", { silent = true })
bind("n", "<leader>gv", ":<C-u>Gvdiff<cr>")
bind("n", "<leader>gt", require("telescope.builtin").git_stash)

bind("n", "<leader>fg", require("telescope.builtin").grep_string, { desc = "Search current Word" })
bind("n", "g/", function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end)
-- bind("n", "/", require('telescope.builtin').current_buffer_fuzzy_find)
bind("n", "g*", function()
  require("telescope.builtin").current_buffer_fuzzy_find({ default_text = vim.fn.expand("<cword>") })
end)

bind("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Search [B]uffers" })
bind("n", "<leader>ff", function(opts)
  opts = opts or {}
  opts.cwd = vim.fn.systemlist("git root")[1]
  require("telescope.builtin").find_files(opts)
end, { desc = "Search [F]iles" })
bind("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Search [H]elp" })
bind("n", "<leader>fG", require("telescope.builtin").live_grep, { desc = "Search by [G]rep" })
bind("n", "<leader>fD", require("telescope.builtin").diagnostics, { desc = "Search [D]iagnostics" })
bind("n", "<leader>fd", function()
  require("telescope.builtin").diagnostics({ bufnr = 0 })
end, { desc = "Search [D]iagnostics" })
bind("n", "<leader>fq", require("telescope.builtin").quickfix, { desc = "Search [Q]uickfix" })
bind("n", "<leader>fk", require("telescope.builtin").keymaps, { desc = "Search [K]eymaps" })
bind("n", "<leader>fs", function()
  require("telescope.builtin").lsp_document_symbols({
    symbols = { "class", "method", "function", "module", "variable", "constant" },
  })
end, { desc = "Document [S]ymbols" })
bind("n", "<leader>fw", require("telescope.builtin").lsp_dynamic_workspace_symbols, { desc = "[W]orkspace Symbols" })
bind("n", "<leader>fr", require("telescope.builtin").lsp_references, { desc = "Find [R]eferences" })
bind("n", "<leader>fm", require("telescope.builtin").marks, { desc = "Find [M]arks" })
bind("n", "<leader>fc", require("telescope.builtin").command_history, { desc = "Find [C]ommands" })
bind("n", "gd", require("telescope.builtin").lsp_definitions, { desc = "[G]oto [D]efinition" })

require("telescope").setup({
  defaults = {
    pickers = {
      find_files = {
        theme = "dropdown",
      },
    },
  },
})

require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "gruvbox-material",
    component_separators = "|",
    section_separators = "",
  },
})

require("indent_blankline").setup({
  show_current_context = true,
})

require("nvim-treesitter.configs").setup({
  auto_install = true,
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    "c",
    "cpp",
    "go",
    "lua",
    "python",
    "rust",
    "vim",
    "bibtex",
    "comment",
    "dockerfile",
    "fish",
    "latex",
    "markdown",
    "markdown_inline",
    "proto",
    "regex",
    "rst",
    "todotxt",
    "toml",
    "org",
    "yaml",
  },
  textobjects = {
    select = {
      enable = true,
      lookhahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["a,"] = "@parameter.outer",
        ["i,"] = "@parameter.inner",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["a#"] = "@comment.outer",
        ["i#"] = "@comment.inner",
      },
    },
    lsp_interop = {
      enable = true,
      border = "none",
      peek_definition_code = {
        ["<leader>kf"] = "@function.outer",
        ["<leader>kc"] = "@class.outer",
      },
    },
  },
  textsubjects = {
    enable = true,
    prev_selection = ":", -- (Optional) keymap to select the previous selection
    keymaps = {
      ["."] = "textsubjects-smart",
      ["aa"] = "textsubjects-container-outer",
      ["ia"] = "textsubjects-container-inner",
    },
  },
  matchup = {
    enable = true,
  },
})

require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })

    map("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })

    -- Actions
    map("n", "<leader>gs", gs.stage_hunk)
    map("n", "<leader>gu", gs.undo_stage_hunk)
    map("n", "<leader>gr", gs.reset_hunk)
    map("n", "<leader>gp", gs.preview_hunk)
    map("n", "<leader>gB", function()
      gs.blame_line({ full = true })
    end)
    map("n", "<leader>gb", gs.toggle_current_line_blame)
    map("n", "<leader>gd", gs.diffthis)
    map("n", "<leader>gD", function()
      gs.diffthis("~")
    end)

    -- Text object
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
  end,
})

require("mason-lspconfig").setup({
  ensure_installed = {
    rust_analyzer = {},
    pylsp = {},
    lua_ls = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  automatic_installation = true,
})

require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "~/.snippets/snippets" } })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
