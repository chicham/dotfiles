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

require("custom.coderpad")

-- vim: ts=2 sts=2 sw=2 et
