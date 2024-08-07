return {
  "goerz/jupytext.vim",
  config = function()
    vim.g.jupytext_enable = 1
    vim.g.jupytext_fmt = "py:percent"
  end,
}
