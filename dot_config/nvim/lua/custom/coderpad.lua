-- CoderPad practice mode: makes Neovim behave like the CoderPad interview
-- editor -- a bare pad with syntax highlighting and formatting, but none of
-- the automatic "intelligence" that would be unfair to lean on.
--
-- Turned off in practice mode (the passive helpers that act on their own):
--   * blink.cmp completion popup -> no LSP/Copilot/snippet autocomplete and
--     no auto signature help (blink owns it)
--   * diagnostics                -> no squiggles, no inline text
--
-- Kept: treesitter highlighting and indentation, treesitter-context, conform
-- format-on-save, and every motion, text object, fold and git mapping.
--
-- LSP clients stay alive on purpose: it keeps definition-based folding working
-- and makes the toggle reversible. Manual lookups (K hover, gK signature,
-- go-to-definition, code actions) therefore still work -- they never fire on
-- their own, so they do not help unless deliberately asked for.
--
-- The blink toggles below are the same lever without the rest of the mode.

vim.api.nvim_create_user_command("BlinkToggle", function()
  vim.g.blink_disable = not vim.g.blink_disable
  print("blink.cmp " .. (vim.g.blink_disable and "OFF" or "ON"))
end, { desc = "Toggle blink.cmp globally" })

vim.api.nvim_create_user_command("BlinkToggleBuffer", function()
  vim.b.blink_disable = not vim.b.blink_disable
  print("blink.cmp (buffer) " .. (vim.b.blink_disable and "OFF" or "ON"))
end, { desc = "Toggle blink.cmp for current buffer" })

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
