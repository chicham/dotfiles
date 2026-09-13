-- Neovim Configuration
-- This file serves as the main entry point for your Neovim setup.
-- It bootstraps the plugin manager, sets fundamental editor options,
-- defines global keybindings, and configures core plugins.
--
-- Fast, focused configuration for efficient editing

--------------------------------------------------------------------------------
-- GLOBAL SETTINGS
--------------------------------------------------------------------------------
-- Set leader key before loading plugins. The leader key is a prefix for custom keybindings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable vim-matchup treesitter engine for markdown: injection parsing
-- triggers node:range() on stale nodes in nvim 0.12 (see inbox.org todo).
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

--------------------------------------------------------------------------------
-- KEY MAPPINGS
--------------------------------------------------------------------------------

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
-- Read live state (vim.diagnostic.is_enabled) as the source of truth so this
-- toggle stays in sync with anything else that flips diagnostics (e.g. the
-- CoderPad practice mode defined at the bottom of this file).
local function toggle_diagnostics()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end

vim.keymap.set("n", "<leader>dt", toggle_diagnostics, {
  desc = "Toggle diagnostics",
  silent = true,
  noremap = true,
})

-- Exit terminal mode in the builtin terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Windows management
vim.keymap.set("n", "<leader>ww", "<C-w><C-w>zt", { silent = true })
vim.keymap.set("n", "<leader>wv", "<C-w>vzt", { silent = true })
vim.keymap.set("n", "<leader>wh", "<C-w>szt", { silent = true })
vim.keymap.set("n", "<leader>wc", "<C-w>c")
vim.keymap.set("n", "<leader>w=", "<C-w>=")
vim.keymap.set("n", "<leader>wr", "<C-w>r")
vim.keymap.set("n", "<leader>wo", "<C-w>o")
vim.keymap.set("n", "<leader><Up>", "<C-w><Up>")
vim.keymap.set("n", "<leader><Down>", "<C-w><Down>")
vim.keymap.set("n", "<leader><Right>", "<C-w><Right>")
vim.keymap.set("n", "<leader><Left>", "<C-w><Left>")

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right window" })

-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { silent = true })

-- Better movement on wrapped lines
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Macro helpers
vim.keymap.set("n", "Q", "@@")
vim.keymap.set("x", "Q", ":normal @@<CR>")

-- Write buffer
vim.keymap.set("n", "W", ":w<cr>", { silent = true })

-- Utility shortcuts
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true }) -- Quick quit
vim.keymap.set("n", "<leader>Q", ":qa!<CR>", { silent = true }) -- Force quit all

-- Tab controls
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { silent = true }) -- New tab
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { silent = true }) -- Close tab
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { silent = true }) -- Close other tabs

-- Folding: code files auto-open as an outline (see lua/custom/plugins/origami.lua).
-- Treesitter folds whole function/method nodes + comments, so every function
-- collapses to a single line (its signature) and all class methods stay visible.

-- Function-like and class-like treesitter node types (used to find the def the
-- cursor sits in). Functions fold whole; classes don't (their methods show).
local fold_fn_types = {
  function_definition = true,
  function_declaration = true,
  function_expression = true,
  arrow_function = true,
  generator_function = true,
  generator_function_declaration = true,
  method_definition = true,
  method_declaration = true,
  constructor_declaration = true,
  function_item = true,
  func_literal = true,
  lambda_expression = true,
  closure_expression = true,
  method = true,
  singleton_method = true,
}
local fold_class_types = {
  class_definition = true,
  class_declaration = true,
  class_specifier = true,
  struct_item = true,
  struct_specifier = true,
  trait_item = true,
  impl_item = true,
  enum_item = true,
  mod_item = true,
  module = true,
  class = true,
  interface_declaration = true,
  namespace_definition = true,
  type_declaration = true,
}

-- Walk up from the cursor to the nearest function/method or class node.
local function fold_enclosing_def()
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then
    return nil
  end
  while node do
    local t = node:type()
    if fold_fn_types[t] or fold_class_types[t] then
      return node
    end
    node = node:parent()
  end
  return nil
end

-- The line where this node's fold starts. Whole-function folds are anchored on the
-- signature line (the function node's own first line), so that is the fold start.
local function fold_start_line(node)
  return node:start() + 1
end

-- All function/method fold start lines under a node (for toggling a whole class).
local function collect_fn_fold_lines(node, acc)
  for child in node:iter_children() do
    if fold_fn_types[child:type()] then
      acc[#acc + 1] = fold_start_line(child)
    end
    collect_fn_fold_lines(child, acc)
  end
end

-- <leader>zz: toggle the current function/method fold. On a class, toggle all of
-- its method folds at once. Works from the signature line too.
vim.keymap.set("n", "<leader>zz", function()
  local node = fold_enclosing_def()
  if not node then
    vim.notify("No enclosing function/class/method", vim.log.levels.WARN)
    return
  end
  local lines = {}
  if fold_class_types[node:type()] then
    collect_fn_fold_lines(node, lines)
  else
    lines = { fold_start_line(node) }
  end
  if #lines == 0 then
    return
  end
  local any_open = false
  for _, l in ipairs(lines) do
    if vim.fn.foldclosed(l) == -1 then
      any_open = true
      break
    end
  end
  local save = vim.api.nvim_win_get_cursor(0)
  for _, l in ipairs(lines) do
    pcall(vim.cmd, l .. (any_open and "foldclose" or "foldopen"))
  end
  pcall(vim.api.nvim_win_set_cursor, 0, save)
end, { desc = "Fold: toggle current function/method (or all methods of a class)" })

-- <leader>za: collapse the whole file <-> expand the whole file.
vim.keymap.set("n", "<leader>za", function()
  vim.wo.foldlevel = vim.wo.foldlevel > 0 and 0 or 99
end, { desc = "Fold: toggle entire file (collapse/expand all)" })

-- <leader>zo: reset to the outline view (bodies + comments folded).
vim.keymap.set("n", "<leader>zo", function()
  vim.wo.foldlevel = 0
end, { desc = "Fold: reset to outline" })

-- Visual mode indent fix
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

-- Move text up and down
vim.keymap.set("x", "J", ":m .+1<CR>==", { silent = true })
vim.keymap.set("x", "K", ":m .-2<CR>==", { silent = true })
vim.keymap.set("x", "p", '"_dP', { silent = true }) -- Don't lose yanked text when pasting over selection

-- Keep cursor centered when jumping
vim.keymap.set("n", "J", "mzJ`z", { silent = true })

-- Miscellaneous keymaps
vim.keymap.set("n", "<leader>pp", ":let @+ = join([expand('%:p'), line('.')], ':')<cr>", { silent = true })
vim.keymap.set("n", "0", "^")

-- Basic Autocommands
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Remember cursor position when reopening files
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line
    if line("'\"") > 0 and line("'\"") <= line("$") then
      vim.cmd('normal! g`"')
    end
  end,
})

-- Auto-resize panes on terminal resize
vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})

-- Ensure wrap is always on for all buffers
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  pattern = "*",
  callback = function()
    vim.wo.wrap = true
  end,
})

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
-- lazy.nvim's setup function loads and configures all specified plugins.
-- The `ui` table customizes the appearance of lazy.nvim's interface.
require("lazy").setup({
  "NMAC427/guess-indent.nvim", -- Detect tabstop and shiftwidth automatically

  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    -- VeryLazy rather than VimEnter: the popup is delayed 300ms behind a
    -- keypress, so it cannot be needed before the first screen draw.
    event = "VeryLazy",
    opts = {
      -- Show the popup only after a deliberate pause, so it helps when you
      -- hesitate but stays out of the way during fluent editing.
      -- (independent of vim.o.timeoutlen)
      delay = 300,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = "<Up> ",
          Down = "<Down> ",
          Left = "<Left> ",
          Right = "<Right> ",
          C = "<C-…> ",
          M = "<M-…> ",
          D = "<D-…> ",
          S = "<S-…> ",
          CR = "<CR> ",
          Esc = "<Esc> ",
          ScrollWheelDown = "<ScrollWheelDown> ",
          ScrollWheelUp = "<ScrollWheelUp> ",
          NL = "<NL> ",
          BS = "<BS> ",
          Space = "<Space> ",
          Tab = "<Tab> ",
          F1 = "<F1>",
          F2 = "<F2>",
          F3 = "<F3>",
          F4 = "<F4>",
          F5 = "<F5>",
          F6 = "<F6>",
          F7 = "<F7>",
          F8 = "<F8>",
          F9 = "<F9>",
          F10 = "<F10>",
          F11 = "<F11>",
          F12 = "<F12>",
        },
      },

      -- Document existing key chains
      spec = {
        { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
        { "<leader>d", group = "[D]iagnostics" },
        { "<leader>f", group = "[F]ind" },
        { "<leader>h", group = "[H]unk (git)" },
        { "<leader>t", group = "[T]abs" },
        { "<leader>w", group = "[W]indow" },
        { "<leader>o", group = "[O]rgmode" },
        { "<leader>n", group = "[N]otes (Roam)" },
        { "<leader>r", group = "[R]efactor" },
        { "<leader>z", group = "[Z] Folds" },
        -- Prefixes introduced by the plugin changes (surround, motions).
        { "s", group = "Surround", mode = { "n", "x" } },
        { "]", group = "Next" },
        { "[", group = "Prev" },
      },
    },
  },

  -- Vim plugins
  "tpope/vim-repeat",
  {
    "tummetott/unimpaired.nvim",
    opts = {
      -- Disable arg ([a ]a [A ]A) and file ([f ]f) nav: those keys are
      -- owned by nvim-treesitter-textobjects @parameter / @function moves.
      -- Buffer (]b), loclist (]l), quickfix (]q), tab (]t), toggles (yo*)
      -- all stay on unimpaired.
      keymaps = {
        previous = false,
        next = false,
        first = false,
        last = false,
        previous_file = false,
        next_file = false,
      },
    },
  },

  -- Import plugins from custom directory
  { import = "custom.plugins" },
  -- Lua LSP configuration
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

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

  -- Plenary - utilities library
  { "nvim-lua/plenary.nvim" },

  -- Chezmoi integration
  {
    "andre-kotake/nvim-chezmoi",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("nvim-chezmoi").setup({
        edit = {
          apply_on_save = "never", -- Options: "auto", "confirm", "never"
        },
        window = {
          execute_template = {
            relative = "editor",
            style = "minimal",
            border = "single",
          },
        },
      })
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
    event = "VimEnter",
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

  -- Catppuccin Theme (main theme)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      -- Apply the colorscheme immediately
      vim.cmd.colorscheme("catppuccin")
    end,
  },
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
