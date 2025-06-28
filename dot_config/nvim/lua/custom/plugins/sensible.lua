return {
  'tpope/vim-sensible',
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd [[ runtime! plugin/sensible.vim ]]
  end,
}
