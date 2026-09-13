-- CoderPad practice mode: makes Neovim behave like the CoderPad interview
-- editor -- a bare pad with syntax highlighting and formatting, but none of
-- the automatic "intelligence" that would be unfair to lean on.
--
-- Turned off in practice mode (the passive helpers that act on their own):
--   * blink.cmp completion popup -> no LSP/Copilot/snippet autocomplete and
--     no auto signature help (blink owns it)
--   * diagnostics                -> no squiggles, no inline text
--   * snacks.words               -> no automatic highlighting of the other
--     occurrences of the word under the cursor
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
  vim.notify("blink.cmp " .. (vim.g.blink_disable and "OFF" or "ON"))
end, { desc = "Toggle blink.cmp globally" })

vim.api.nvim_create_user_command("BlinkToggleBuffer", function()
  vim.b.blink_disable = not vim.b.blink_disable
  vim.notify("blink.cmp (buffer) " .. (vim.b.blink_disable and "OFF" or "ON"))
end, { desc = "Toggle blink.cmp for current buffer" })

vim.g.coderpad = false

-- snacks.words highlights every other occurrence of the word under the cursor
-- on its own, which is the same class of help as completion.
--
-- snacks turns it on from the first LspAttach (snacks/init.lua's event table),
-- so a one-off disable() taken before any server has attached is undone a few
-- milliseconds later. Hooking the same event instead is deterministic: this
-- autocommand is registered after snacks' own, so within one LspAttach it runs
-- second and has the last word. The immediate call covers the buffers that
-- already had a server when the mode was switched on.
---@param on boolean
local function scope_words(on)
  if not (Snacks and Snacks.words) then
    return
  end
  pcall(vim.api.nvim_del_augroup_by_name, "coderpad_words")
  if not on then
    Snacks.words.enable()
    return
  end
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("coderpad_words", { clear = true }),
    callback = function()
      Snacks.words.disable()
    end,
  })
  Snacks.words.disable()
end

local function coderpad_apply(on)
  vim.g.coderpad = on
  vim.g.blink_disable = on -- completion + Copilot + auto signature help
  vim.diagnostic.enable(not on) -- error/warning squiggles + tiny-inline-diagnostic

  scope_words(on)

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
-- Only "1" arms it: an exported CODERPAD=0 is how the mode is turned off for
-- one command in a shell that sets it, and `~= nil` would arm it there.
if vim.env.CODERPAD == "1" then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(function()
        coderpad_apply(true)
      end)
    end,
  })
end
