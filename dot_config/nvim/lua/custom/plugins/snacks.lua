-- snacks.nvim, for its `input` module only.
--
-- fzf-lua already owns `vim.ui.select` (see fzf-lua.lua), but it is a finder
-- and cannot provide `vim.ui.input`, which otherwise falls back to the
-- command-line prompt. jj.nvim asks for text through `vim.ui.input` in fifteen
-- places -- describe, revset entry in the log buffer, bookmark and tag names --
-- so every one of those becomes a float positioned at the cursor.
--
-- This does not reach the two prompts in the review loop: quickfix-review's
-- comment box and anything else built on `vim.fn.input`, which no ui plugin can
-- intercept.
--
-- Every other snacks module stays disabled: the picker in particular would sit
-- alongside fzf-lua and split the config across two finder UIs.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = { enabled = true },
  },
}
