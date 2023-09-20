return {
  "goerz/jupytext.vim",
  config = function()
    vim.g.jupytext_enable = true
    vim.g.jupytext_fmt = "py:percent"
  end,
}
