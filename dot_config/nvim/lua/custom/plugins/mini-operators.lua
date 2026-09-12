-- Operators (replaces tommcdo/vim-exchange). Standalone mini module.
-- Provides exchange, replace, sort, evaluate, multiply as operators + line + visual.
return {
  "echasnovski/mini.operators",
  version = false,
  keys = {
    -- exchange: cx{motion} / cxx (line) / cx (visual) -- matches old vim-exchange
    { "cx", mode = { "n", "x" }, desc = "Exchange (operator)" },
    { "gR", mode = { "n", "x" }, desc = "Replace with register (operator)" },
    { "gs", mode = { "n", "x" }, desc = "Sort (operator)" },
    { "g=", mode = { "n", "x" }, desc = "Evaluate (operator)" },
  },
  opts = {
    evaluate = { prefix = "g=" },
    -- exchange on cx (not gx) so Neovim's built-in gx (open URL/file) is kept.
    exchange = { prefix = "cx" },
    -- multiply disabled: its default 'gm' collides with marks.nvim's preview
    -- mapping. Re-enable on a free key if wanted (e.g. prefix = 'gM').
    multiply = { prefix = "" },
    -- replace on gR (not gr) to avoid Neovim's built-in LSP grr/gra/grn/gri.
    replace = { prefix = "gR" },
    sort = { prefix = "gs" },
  },
}
