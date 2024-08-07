return {
  "https://github.com/lervag/vimtex",
  lazy = false,
  init = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_compiler_method = "latexrun"
  end,
}
