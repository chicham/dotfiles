return {
  "ggandor/leap.nvim",
  keys = {
    { ",", "<Plug>(leap-forward-to)", mode = { "n", "o", "x" } },
    { ";", "<Plug>(leap-backward-to)", mode = { "n", "o", "x" } },
    { "g,", "<Plug>(leap-from-window)", mode = { "n", "o", "x" } },
  },
  opts = {
    safe_labels = { "t", "s", "r", "n", "m", "e", "i", "u", "a" },
    labels = { "t", "s", "r", "n", "m", "e", "i", "u", "a", "v", "d", "l", "j", "z", "b", "é", "p", "o" },
  },
}
