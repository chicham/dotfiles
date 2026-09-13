-- The colorscheme. Eager and high priority so it is applied before any other
-- plugin draws, otherwise the first frames render in the default theme.
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  config = function()
    vim.cmd.colorscheme("catppuccin")
  end,
}
