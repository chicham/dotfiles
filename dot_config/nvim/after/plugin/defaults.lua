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

-- Set colorscheme
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

bind('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
bind('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--Windows management
bind("n", "<leader><Bar>", '"<C-W>v<C-W><Right>zt"', { expr = true, silent = true })
bind("n", "<leader>_", '"<C-W>s<C-W><Down>zt"', { expr = true, silent = true })
bind("n", "<leader><Up>", "<C-w><Up>")
bind("n", "<leader><Down>", "<C-w><Down>")
bind("n", "<leader><Right>", "<C-w><Right>")
bind("n", "<leader><Left>", "<C-w><Left>")
bind("n", "<leader>wc", "<C-w>c")
bind("n", "<leader>w=", "<C-w>=")
bind("n", "<leader>wr", "<C-w>r")
bind("n", "<leader>wo", "<C-w>o")

-- Macros helpers
bind("n", "Q", "@@")
bind("v", ".", ":normal .")
bind("v", "Q", ":normal @@")

-- Write buffer
bind("n", "W", ":w<cr>", { silent = true })

-- Visual model indent fix
bind("v", "<", "<gv")
bind("v", ">", ">gv")

-- Switch mro
bind("n", "<leader><leader>", "<C-^>")

-- fugitive bindings
bind('n', '<leader>gg', ':<C-u>0Git<cr>', { silent = true })
bind('n', '<leader>gw', ':<C-u>Gwrite<cr>')
bind('n', '<leader>gW', ':<C-u>Gwrite!<cr>')
bind('n', '<leader>g+', ':<C-u>Git stash<cr>:e<cr>')
bind('n', '<leader>g-', ':<C-u>Git stash pop<cr>:e<cr>')
bind('n', '<leader>go', ":execute line('.') . ',GBrowse'<cr>", { silent = true })
bind('n', '<leader>g3', ":diffget //3<cr>")
bind('n', '<leader>g2', ":diffget //2<cr>")
bind('n', '<leader>gv', ":<C-u>Gvdiff<cr>")
bind('n', '<leader>gs', require('telescope.builtin').git_stash)

bind('n', '<leader>fo', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
-- bind("n", "<leader>f/", require("telescope.builtin").treesitter, { desc = "[/] Search symbols in current buffer]" })
bind("n", "<leader>fg", require("telescope.builtin").grep_string, { desc = "Search current Word" })
bind('n', 'g/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end
)
-- bind("n", "/", require('telescope.builtin').current_buffer_fuzzy_find)
bind("n", "g*", function() require('telescope.builtin').current_buffer_fuzzy_find({default_text=vim.fn.expand("<cword>")}) end)

bind("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Search [B]uffers" })
bind("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Search [F]iles" })
bind("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Search [H]elp" })
bind("n", "<leader>fG", require("telescope.builtin").live_grep, { desc = "Search by [G]rep" })
bind("n", "<leader>fD", require("telescope.builtin").diagnostics, { desc = "Search [D]iagnostics" })
bind("n", "<leader>fd",
  function ()
    require("telescope.builtin").diagnostics{ bufnr=0 }
  end,
  { desc = "Search [D]iagnostics" })
bind("n", "<leader>fq", require("telescope.builtin").quickfix, { desc = "Search [Q]uickfix" })
bind("n", "<leader>fk", require("telescope.builtin").keymaps, { desc = "Search [K]eymaps" })
bind("n", "<leader>fs",
  function()
    require("telescope.builtin").lsp_document_symbols { symbols = { "class", "method", "function", "module", "variable", "constant" } }
  end,
  { desc = "Document [S]ymbols" }
)
bind("n", "<leader>fi", require("telescope.builtin").lsp_incoming_calls, { desc = "[I]ncoming calls" })
bind("n", "<leader>fo", require("telescope.builtin").lsp_outgoing_calls, { desc = "[O]utgoing calls" })
bind("n", "<leader>fw", require("telescope.builtin").lsp_dynamic_workspace_symbols, { desc = "[W]orkspace Symbols" })
bind("n", "<leader>fr", require("telescope.builtin").lsp_references, { desc = "Find [R]eferences" })
bind("n", "<leader>fm", require("telescope.builtin").marks, { desc = "Find [M]arks" })

require("telescope").setup({
  defaults = {
    pickers = {
      find_files = {
        theme = "dropdown",
      },
    },
  },
})

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox-material',
    component_separators = '|',
    section_separators = '',
  },
}

require("indent_blankline").setup({
  show_current_context = true,
})

require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'typescript', 'vim', "bibtex", "make",
    "comment", "dockerfile", "fish", "latex", "markdown", "markdown_inline", "proto", "regex", "rst", "todotxt", "toml",
    "yaml" },
  textobjects = {
    keymaps = {
      -- You can use the capture groups defined in textobjects.scm
      ['aa'] = '@attribute.outer',
      ['ia'] = '@attribute.inner',
      ['a/'] = '@comment.outer',
      ['i/'] = '@comment.inner',
      ['ap'] = '@parameter.outer',
      ['ip'] = '@parameter.inner',
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
  textsubjects = {
    enable = true,
    prev_selection = ",", -- (Optional) keymap to select the previous selection
    keymaps = {
      ["."] = "textsubjects-smart",
      ["ac"] = "textsubjects-container-outer",
      ["ic"] = "textsubjects-container-inner",
    },
  },
  matchup = {
    enable = true,
  },
}

local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.code_actions.gitsigns,
		null_ls.builtins.code_actions.eslint_d,
		null_ls.builtins.code_actions.gitrebase,
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.black,
		null_ls.builtins.formatting.latexindent,
		null_ls.builtins.formatting.beautysh,
		null_ls.builtins.formatting.prettier.with({
			filetypes = { "html", "json", "yaml", "markdown" },
			extra_args = { "--print-width", "4" },
		}),
		null_ls.builtins.diagnostics.eslint,
		null_ls.builtins.diagnostics.chktex,
		null_ls.builtins.diagnostics.fish,
		null_ls.builtins.diagnostics.gitlint,
		null_ls.builtins.diagnostics.luacheck,
		null_ls.builtins.diagnostics.trail_space,
		null_ls.builtins.diagnostics.yamllint,
		null_ls.builtins.diagnostics.ruff
  }
})

require("gitsigns").setup{
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    -- map('n', '<leader>hs', gs.stage_hunk)
    -- map('n', '<leader>hr', gs.reset_hunk)
    -- map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line("."), vim.fn.line("v")} end)
    -- map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line("."), vim.fn.line("v")} end)
    -- map('n', '<leader>hS', gs.stage_buffer)
    -- map('n', '<leader>hu', gs.undo_stage_hunk)
    -- map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>gp', gs.preview_hunk)
    map('n', '<leader>gB', function() gs.blame_line{full=true} end)
    map('n', '<leader>gb', gs.toggle_current_line_blame)
    map('n', '<leader>gd', gs.diffthis)
    map('n', '<leader>gD', function() gs.diffthis('~') end)
    map('n', '<leader>gt', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

require('mason-lspconfig').setup {
  ensure_installed = {
    pyright = {},
    rust_analyzer = {},
    lua_ls = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  automatic_installation = true,
}

require('orgmode').setup_ts_grammar()


-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
