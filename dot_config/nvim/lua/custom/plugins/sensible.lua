return {
  'tpope/vim-sensible',
  config = function()
    vim.cmd [[ runtime! plugin/sensible.vim ]]
  end,
}
