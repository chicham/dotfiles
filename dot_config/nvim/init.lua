-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

if vim.fn.has('vim_starting') == 1 then
  vim.cmd [[
    set all&
  ]]
end

-- stylua: ignore start
local keymap = vim.keymap.set

--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Package manager
  -- better default settings
  use 'tpope/vim-sensible'
  use 'rstacruz/vim-opinion'
  -- Heuristically set buffer options
  use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically
  -- enable repeating supported plugin maps with "."
  use 'tpope/vim-repeat'
  -- Easily search for, substitute, and abbreviate multiple variants of a word
  use 'tpope/vim-abolish'
  -- Range, pattern and substitute preview for Vim
  use 'markonm/traces.vim'
  vim.g.traces_abolish_integration = 1
  --  Set of operators and textobjects to search/select/edit sandwiched texts
  use 'machakann/vim-sandwich'
  keymap('n', 's', '<Nop>', { remap = true })
  keymap('x', 's', '<Nop>', { remap = true })
  keymap('x', 'is', '<Plug>(textobj-sandwich-query-i)')
  keymap('x', 'as', '<Plug>(textobj-sandwich-query-a)')
  keymap('o', 'is', '<Plug>(textobj-sandwich-query-i)')
  keymap('o', 'as', '<Plug>(textobj-sandwich-query-a)')
  keymap('x', 'ib', '<Plug>(textobj-sandwich-auto-i)')
  keymap('x', 'ab', '<Plug>(textobj-sandwich-auto-a)')
  keymap('o', 'ib', '<Plug>(textobj-sandwich-auto-i)')
  keymap('o', 'ab', '<Plug>(textobj-sandwich-auto-a)')
  keymap('x', 'im', '<Plug>(textobj-sandwich-literal-query-i)')
  keymap('x', 'am', '<Plug>(textobj-sandwich-literal-query-a)')
  keymap('o', 'im', '<Plug>(textobj-sandwich-literal-query-i)')
  keymap('o', 'am', '<Plug>(textobj-sandwich-literal-query-a)')
  use('svermeulen/vim-subversive')
  keymap('n', 'gs', '<Plug>(SubversiveSubstitute)')
  keymap('n', 'gss', '<Plug>(SubversiveSubstituteLine)')
  keymap('n', 'gS', '<Plug>(SubversiveSubstituteToEndOfLine')
  use 'tommcdo/vim-exchange'
  vim.g.exchange_no_mappings = true
  vim.keymap.set('n', 'cx', '<Plug>(Exchange)')
  vim.keymap.set('v', 'X', '<Plug>(Exchange)')
  vim.keymap.set('n', 'cxc', '<Plug>(ExchangeClear)')
  vim.keymap.set('n', 'cxx', '<Plug>(ExchangeLine)')
  -- Better join of multiple lines
  use 'AndrewRadev/splitjoin.vim'
  use 'flwyd/vim-conjoin'
  -- Diff in same file
  use 'AndrewRadev/linediff.vim'
  -- Pairs mappings
  use 'tpope/vim-unimpaired'
  -- Unix shell command
  use 'tpope/vim-eunuch'

  -- Show trailling white space
  use 'ntpeters/vim-better-whitespace'
  -- Reopen file at last place edited
  use 'dietsche/vim-lastplace'
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  use 'nvim-treesitter/nvim-treesitter' -- Highlight, edit, and navigate code
  use 'nvim-treesitter/nvim-treesitter-textobjects' -- Additional textobjects for treesitter
  use 'RRethy/nvim-treesitter-textsubjects'
  use 'p00f/nvim-ts-rainbow'
  use 'tpope/vim-fugitive' -- Git commands in nvim
  keymap('n', '<leader>gg', ":<C-u>Git<cr><cr>")
  use 'tpope/vim-rhubarb' -- Fugitive-companion to interact with github
  use 'shumphrey/fugitive-gitlab.vim'
  vim.g.fugitive_gitlab_domains = { "" }
  -- Fugitive-companion to interact with gitlab
  keymap('n', '<leader>gg', ':<C-u>Git<cr>', { silent = true })
  keymap('n', '<leader>gw', ':<C-u>Gwrite<cr>')
  keymap('n', '<leader>gW', ':<C-u>Gwrite!<cr>')
  keymap('n', '<leader>g+', ':<C-u>Git stash<cr>:e<cr>')
  keymap('n', '<leader>g-', ':<C-u>Git stash pop<cr>:e<cr>')
  keymap('n', '<leader>gp', ':<C-u>Git push -u')
  keymap('n', '<leader>go', ":execute line('.') . ',GBrowse'<cr>", { silent = true })
  keymap('n', '<leader>gl', ":diffget //3<cr>")
  keymap('n', '<leader>gr', ":diffget //2<cr>")
  keymap('n', '<leader>gv', ":<C-u>Gvdiff<cr>")
  keymap('n', '<leader>gs', ":<C-u>Gvdiff<cr>")
  keymap('n', '<leader>gs', require('telescope.builtin').git_stash)
  -- Show virtual text for git blame
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Add git related info in the signs columns and popups
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  -- Automatically install language servers to stdpath
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use { 'hrsh7th/nvim-cmp', requires = { 'hrsh7th/cmp-nvim-lsp' } } -- Autocompletion
  use { 'hrsh7th/cmp-copilot', requires = { 'hrsh7th/cmp-nvim-lsp' } } -- Autocompletion
  use 'github/copilot.vim'
  use { 'L3MON4D3/LuaSnip', requires = { 'saadparwaiz1/cmp_luasnip' } } -- Snippet Engine and Snippet Expansion
  use 'mjlbach/onedark.nvim' -- Theme inspired by Atom
  use 'nvim-lualine/lualine.nvim' -- Fancier statusline
  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Fuzzy Finder (files, lsp, etc)

  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable "make" == 1 }
  use 'andymass/vim-matchup'

  if is_bootstrap then
    require('packer').sync()
  end
  use 'morhetz/gruvbox'
  use { "windwp/nvim-autopairs", wants = "nvim-treesitter", config = function() require("nvim-autopairs").setup {
      disable_in_macro = true,
      check_ts = true
    }
  end }
  use 'justinmk/vim-sneak'
  vim.g['sneak#streak'] = true
  vim.g['sneak#s_next'] = true
  vim.g['sneak#use_ic_scs'] = true
  vim.g['sneak#target_labels'] = 'eiuatsrncmopébvdljEIUATSRNCMOPÉBVDLJ'
  -- 2-character Sneak (default)
  vim.keymap.set('n', ',', "<Plug>Sneak_s", { remap = true })
  vim.keymap.set('n', ';', "<Plug>Sneak_S", { remap = true })
  -- visual-mode
  vim.keymap.set('x', ',', "<Plug>Sneak_s", { remap = true })
  vim.keymap.set('x', ';', "<Plug>Sneak_S", { remap = true })
  -- operator-pending-mode
  vim.keymap.set('o', ',', "<Plug>Sneak_s", { remap = true })
  vim.keymap.set('o', ';', "<Plug>Sneak_S", { remap = true })
  -- replace 'f' with 1-char Sneak
  vim.keymap.set('n', 'f', "<Plug>Sneak_f", { remap = true })
  vim.keymap.set('n', 'F', "<Plug>Sneak_F", { remap = true })
  vim.keymap.set('x', 'f', "<Plug>Sneak_f", { remap = true })
  vim.keymap.set('x', 'F', "<Plug>Sneak_F", { remap = true })
  -- replace 't' with 1-char Sneak
  vim.keymap.set('n', 't', "<Plug>Sneak_t", { remap = true })
  vim.keymap.set('n', 'T', "<Plug>Sneak_T", { remap = true })
  vim.keymap.set('x', 't', "<Plug>Sneak_t", { remap = true })
  vim.keymap.set('x', 'T', "<Plug>Sneak_T", { remap = true })
  use 'bruno-/vim-vertical-move'
  use 'mbbill/undotree'
  vim.g.undotree_WindowLayout = 2
  vim.keymap.set('n', 'U', ':<C-u>UndotreeToggle<cr>')
  use 'editorconfig/editorconfig-vim'
  vim.g.EditorConfig_exclude_patterns = { 'fugitive://.*', 'scp://.*' }
  use 'inside/vim-search-pulse'
  vim.g.vim_search_pulse_disable_auto_mappings = true
  vim.g.vim_search_pulse_mode = 'pattern'
  use 'haya14busa/is.vim'
  use 'haya14busa/vim-asterisk'
  vim.g['asterisk#keeppos'] = true
  vim.keymap.set('n', '*', '<Plug>(asterisk-z*)<Plug>Pulse', { remap = true })
  vim.keymap.set('n', '#', '<Plug>(asterisk-z#)<Plug>Pulse', { remap = true })
  vim.keymap.set('n', 'n', ':norm! nzzzv<Plug><Plug>Pulse<cr>', { remap = true })
  vim.keymap.set('n', 'N', ':norm! Nzzzv<Plug><Plug>Pulse<cr>', { remap = true })

  use 'vim-pandoc/vim-pandoc'
  use 'vim-pandoc/vim-pandoc-syntax'
  use 'vim-pandoc/vim-criticmarkup'
  vim.g['pandoc#keyboard#use_default_mappings'] = false
  vim.g['pandoc#formatting#mode'] = false
  vim.g['pandoc#syntax#conceal#use'] = false
  vim.g['pandoc#biblio#use_bibtool'] = true
  use 'goerz/jupytext.vim'
  vim.g.jupytext_enable = true
  vim.g.jupytext_fmt = 'py:percent'
  use 'rickhowe/diffchar.vim'
end)
-- stylua: ignore end

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC',
})

-- Set filetype for exotic extensions
local ftcheck_group = vim.api.nvim_create_augroup('ftcheck', { clear = true })
vim.api.nvim_create_autocmd('BufNewFile,BufRead', {
  command = 'set ft=tex',
  group = ftcheck_group,
  pattern = '*.cls',
})
-- Show trailling whitespace
local trailing_ws_group = vim.api.nvim_create_augroup('trailling_ws', { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', {
  command = ':set listchars-=trail:·',
  group = trailing_ws_group,
  pattern = '*',
})
vim.api.nvim_create_autocmd('InsertLeave', {
  command = ':set listchars+=trail:·',
  group = trailing_ws_group,
  pattern = '*',
})

-- [[ Setting options ]]
local set = vim.opt

-- Set highlight on search
set.hlsearch = false

-- Make line numbers default
set.number = true
set.relativenumber = true

-- Save undo history
set.undofile = true

-- Decrease update time
set.updatetime = 250
set.signcolumn = 'yes'

-- Clipboard
set.clipboard = 'unnamedplus'

-- Set colorscheme
set.termguicolors = true
vim.cmd [[colorscheme gruvbox]]

-- Set completeopt to have a better completion experience
set.completeopt = 'menuone,longest'
set.cursorline = true

set.list = true
set.listchars = { tab = '▸ ', trail = '·' }
set.wrap = true
set.linebreak = true
set.showbreak = '>>'

if vim.fn.executable('rg') == 1 then
  vim.o.grepprg = "rg --vimgrep --smart-case --follow --hidden --glob '!.git'"
end

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
-- vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', '<Up>', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', '<Down>', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--Windows management
vim.keymap.set('n', '<leader><Bar>', '"<C-W>v<C-W><Right>zt"', { expr = true, silent = true })
vim.keymap.set('n', '<leader>_', '"<C-W>s<C-W><Down>zt"', { expr = true, silent = true })
vim.keymap.set('n', '<leader><Up>', "<C-w><Up>")
vim.keymap.set('n', '<leader><Down>', "<C-w><Down>")
vim.keymap.set('n', '<leader><Right>', "<C-w><Right>")
vim.keymap.set('n', '<leader><Left>', "<C-w><Left>")
vim.keymap.set('n', '<leader>wc', "<C-w>c")
vim.keymap.set('n', '<leader>w=', "<C-w>=")
vim.keymap.set('n', '<leader>wr', "<C-w>r")
vim.keymap.set('n', '<leadeo>wo', "<C-w>o")
-- vim.keymap.set('n', '<leader>wh', "<C-w>t<C-w>K")
-- vim.keymap.set('n', '<leader>wv', "<C-w>t<C-w>H")
vim.keymap.set('n', '<leader>wR', "<C-w>R")

-- Macros helpers
vim.keymap.set('n', 'Q', "@@")
vim.keymap.set('v', '.', ":normal .")
vim.keymap.set('v', 'Q', ":normal @@")

-- Write buffer
vim.keymap.set('n', 'W', ":w<cr>", { silent = true })

-- Visual model indent fix
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Switch mro
vim.keymap.set('n', '<leader><leader>', "<C-^>")


-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Set lualine as statusline
-- See `:help lualine.txt`
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'jellybeans',
    component_separators = '|',
    section_separators = '',
  },
}

-- Enable Comment.nvim
require('Comment').setup()


-- Enable `lukas-reineke/indent-blankline.nvim`
-- See `:help indent_blankline.txt`
require('indent_blankline').setup {
  char = '┊',
  show_trailing_blankline_indent = false,
}

-- Gitsigns
-- See `:help gitsigns.txt`
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-h>'] = "which_key",
      },
    },
    pickers = {
      find_files = {
        theme = "dropdown"
      }
    }
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')


-- See `:help telescope.builtin`
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')
keymap('n', '<leader>f/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer]' })

keymap('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Search [F]iles' })
keymap('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = 'Search [H]elp' })
keymap('n', '<leader>fg', require('telescope.builtin').grep_string, { desc = 'Search current Word' })
keymap('n', '<leader>fG', require('telescope.builtin').live_grep, { desc = 'Search by [G]rep' })
keymap('n', '<leader>fd', require('telescope.builtin').diagnostics, { desc = 'Search [D]iagnostics' })
keymap('n', '<leader>fq', require('telescope.builtin').quickfix, { desc = 'Search [Q]uickfix' })
keymap('n', '<leader>fk', require('telescope.builtin').keymaps, { desc = 'Search [K]eymaps' })
keymap('n', '<leader>fs', require('telescope.builtin').lsp_document_symbols, { desc = 'Search [S]ymbols' })
keymap('n', '<leader>fi', require('telescope.builtin').lsp_incoming_calls, { desc = '[I]ncoming calls' })
keymap('n', '<leader>fo', require('telescope.builtin').lsp_outgoing_calls, { desc = '[O]utgoing calls' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'lua', 'typescript', 'rust', 'go', 'python', 'bibtex', 'c', 'cmake', 'comment', 'cpp',
    'dockerfile', 'fish', 'help', 'json', 'json5', 'latex', 'proto', 'regex', 'rst', 'todotxt', 'yaml' },
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      -- TODO: I'm not sure for this one.
      scope_incremental = '<c-s>',
      node_decremental = '<c-backspace>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['il'] = '@loop.inner',
        ['al'] = '@loop.outer',
        ['ip'] = '@parameter.inner',
        ['ap'] = '@parameter.outer',
        ['it'] = '@statement.inner',
        ['at'] = '@statement.outer',
        ['ax'] = '@comment.outer',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
    lsp_interop = {
      enable = true,
      border = "none",
      peek_definition_code = {
        ["<leader>df"] = "@function.outer",
        ["<leader>dF"] = "@class.outer",
      },
    },
  },
  textsubjects = {
    enable = true,
    prev_selection = ',', -- (Optional) keymap to select the previous selection
    keymaps = {
      ['.'] = 'textsubjects-smart',
      ['ac'] = 'textsubjects-container-outer',
      ['ic'] = 'textsubjects-container-inner',
    },
  },
  matchup = {
    enable = true,
  },
  rainbow = {
    enable = true,
    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
    -- colors = {}, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
  }
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>cr', vim.lsp.buf.rename, '[R]ename')
  nmap('<leader>ca', vim.lsp.buf.code_action, 'Code [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('gr', require('telescope.builtin').lsp_references)
  nmap('<leader>cd', require('telescope.builtin').lsp_document_symbols, '[D]ocument Symbols')
  nmap('<leader>cw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace Symbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('H', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>ct', vim.lsp.buf.type_definition, '[T]ype Definition')
  -- nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  -- nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  -- nmap('<leader>wl', function()
  -- print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  -- end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', vim.lsp.buf.format or vim.lsp.buf.formatting,
    { desc = 'Format current buffer with LSP' })
end

vim.cmd [[
runtime! plugin/sensible.vim
runtime! plugin/opinion.vim
runtime! macros/sandwich/keymap/surround.vim
]]

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Enable the following language servers

require("mason").setup {
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    }
  }
}

-- local servers = { 'clangd', 'rust_analyzer', 'pyright', 'sumneko_lua', 'grammarly-languageserver' , 'dockerls', 'texlab', 'editorconfig-checker', 'gitlint', 'flake8', 'isort', 'prettier', 'luaformatter'}
local servers = { "sumneko_lua", "rust_analyzer", "pyright", "grammarly", "dockerls", "texlab", "editorconfig-checker",
  "black", "gitlint", "luaformatter", "isort", "prettier" }
require("mason-lspconfig").setup {
  ensure_installed = servers,
}

-- Example custom configuration for lua
--
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

require('lspconfig').sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = { library = vim.api.nvim_get_runtime_file('', true) },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = { enable = false, },
    },
  },
}

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'copilot' }
  },
}

require("nvim-autopairs").setup({
  enable_check_bracket_line = false, -- Don't add pairs if it already has a close pair in the same line
  ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
  check_ts = true, -- use treesitter to check for a pair.
  ts_config = {
    lua = { "string" }, -- it will not add pair on that treesitter node
    javascript = { "template_string" },
    java = false, -- don't check treesitter on java
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et