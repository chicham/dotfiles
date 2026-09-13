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
