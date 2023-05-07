local options = vim.opt
-- Set highlight on search
options.hlsearch = false

-- Make line numbers default
options.number = true
options.relativenumber = true

-- Save undo history
options.undofile = true

-- Decrease update time
options.updatetime = 250
options.signcolumn = "yes"

-- Clipboard
options.clipboard = "unnamedplus"

-- Set colorscheme
options.termguicolors = true

-- Set completeopt to have a better completion experience
options.completeopt = "menuone,longest,noinsert"
options.cursorline = true

options.list = true
options.listchars = { tab = "▸ ", trail = "·" }
options.wrap = true
options.linebreak = true
options.showbreak = ">>"

if vim.fn.executable("rg") == 1 then
  vim.o.grepprg = "rg --vimgrep --smart-case --follow --hidden --glob '!.git'"
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
bind('n', '<leader>gg', ':<C-u>Git<cr>', { silent = true })
bind('n', '<leader>gw', ':<C-u>Gwrite<cr>')
bind('n', '<leader>gW', ':<C-u>Gwrite!<cr>')
bind('n', '<leader>g+', ':<C-u>Git stash<cr>:e<cr>')
bind('n', '<leader>g-', ':<C-u>Git stash pop<cr>:e<cr>')
bind('n', '<leader>gp', ':<C-u>Git push -u')
bind('n', '<leader>go', ":execute line('.') . ',GBrowse'<cr>", { silent = true })
bind('n', '<leader>gl', ":diffget //3<cr>")
bind('n', '<leader>gr', ":diffget //2<cr>")
bind('n', '<leader>gv', ":<C-u>Gvdiff<cr>")
bind('n', '<leader>gs', require('telescope.builtin').git_stash)

bind('n', '<leader>fo', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
-- bind("n", "<leader>f/", require("telescope.builtin").treesitter, { desc = "[/] Search symbols in current buffer]" })
bind("n", "<leader>fg", require("telescope.builtin").grep_string, { desc = "Search current Word" })
-- bind('n', 'g/', function()
--   -- You can pass additional configuration to telescope to change theme, layout, etc.
--   require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
--     winblend = 10,
--     previewer = false,
--   })
bind("n", "/", require('telescope.builtin').current_buffer_fuzzy_find)
bind("n", "g*", function() require('telescope.builtin').current_buffer_fuzzy_find({default_text=vim.fn.expand("<cword>")}) end)

bind("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Search [B]uffers" })
bind("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Search [F]iles" })
bind("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Search [H]elp" })
bind("n", "<leader>fG", require("telescope.builtin").live_grep, { desc = "Search by [G]rep" })
bind("n", "<leader>fd", require("telescope.builtin").diagnostics, { desc = "Search [D]iagnostics" })
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
    theme = 'jellybeans',
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
      ['ax'] = '@block.outer',
      ['ix'] = '@block.inner',
      ['at'] = '@call.outer',
      ['it'] = '@call.inner',
      ['ac'] = '@class.outer',
      ['ic'] = '@class.inner',
      ['a/'] = '@comment.outer',
      ['i/'] = '@comment.inner',
      ['ad'] = '@conditional.outer',
      ['id'] = '@conditional.inner',
      ['af'] = '@function.outer',
      ['if'] = '@function.inner',
      ['al'] = '@loop.outer',
      ['il'] = '@loop.inner',
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

require("cmp").setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'git' },
    { name = "path" },
		{ name = 'copilot' },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
