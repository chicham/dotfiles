-- Editor options and the globals that have to be set before plugins load.
--
-- Required by lazy.nvim to run first: the leader keys (every plugin spec's
-- `keys` is resolved against them) and vim.g.matchup_treesitter_disabled,
-- which vim-matchup reads in its autoload before this config could reach it.

--------------------------------------------------------------------------------
-- GLOBAL SETTINGS
--------------------------------------------------------------------------------
-- Set leader key before loading plugins. The leader key is a prefix for custom keybindings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable vim-matchup treesitter engine for markdown: injection parsing
-- triggers node:range() on a stale node on nvim 0.12, which errors on every
-- cursor move in a fenced code block.
-- Must be set before vim-matchup's autoload fires so s:init_option skips it.
vim.g.matchup_treesitter_disabled = { "markdown", "markdown_inline" }

-- Set to true if you have a Nerd Font installed and selected in the terminal.
-- Nerd Fonts provide additional icons and glyphs for various plugins (e.g., lualine, nvim-tree).
vim.g.have_nerd_font = true

--------------------------------------------------------------------------------
-- BASIC SETTINGS
--------------------------------------------------------------------------------
-- Make line numbers default (absolute line numbers)
vim.opt.number = true
-- Show relative line numbers (useful for motions like 5j, 10k)
vim.opt.relativenumber = true

-- Enable mouse mode for easier navigation and resizing
vim.opt.mouse = "a"

-- Don't show the mode in the command line, as it's already in the status line (e.g., lualine)
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim. This allows you to copy/paste to/from external applications.
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent: preserves indentation when wrapping lines
vim.opt.breakindent = true

-- Save undo history to a file, allowing undo/redo even after closing Neovim
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C is used or one or more capital letters are in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Always show the signcolumn, preventing text from jumping when diagnostics or git signs appear
vim.opt.signcolumn = "yes"

-- Decrease update time for plugins and UI, making Neovim feel more responsive
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time, making keybindings feel snappier
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened: vertical splits to the right, horizontal splits below
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type! (e.g., :s/old/new/gc)
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor when scrolling
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.opt.confirm = true

-- Default border for every floating window that does not set its own, so
-- hover, signature help, diagnostics and plugin floats match without each
-- being configured separately.
vim.opt.winborder = "rounded"

-- completion menu behaviour
vim.opt.completeopt = "menu,menuone,noselect,noinsert"

-- Command Line settings
vim.opt.cmdheight = 1 -- Command line height
vim.opt.wildmenu = true -- Enable wildmenu for command-line completion
vim.opt.wildmode = "longest:full,full" -- Command line completion behavior

-- Use ripgrep as grepprg if available for faster and more powerful grep searches
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case --follow --hidden --glob '!.git'"
end

-- Wrap behavior: wrap long lines and break them at word boundaries
vim.opt.wrap = true
vim.opt.linebreak = true
-- Diff options for better visual diffs
vim.opt.diffopt = "filler,internal,algorithm:histogram,indent-heuristic"

-- File/Buffer Handling
vim.opt.hidden = true -- Hide buffers when not in use instead of closing them
vim.opt.swapfile = false -- Disable swap files
vim.opt.backup = false -- Disable backup files
vim.opt.spell = false -- Disable spell checking by default
vim.opt.spelllang = "en_us" -- Default spell language

-- Appearance
vim.opt.fillchars:append({ eob = " " }) -- Don't show ~ for empty lines at the end of the buffer
vim.opt.termguicolors = true -- Enable true colors in the terminal

-- Indentation settings
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2 -- Number of spaces to use for autoindent and shift commands
vim.opt.tabstop = 2 -- Number of spaces a tab character represents
vim.opt.softtabstop = 2 -- Number of spaces a tab character represents when editing
vim.opt.smartindent = true -- Smart autoindenting
