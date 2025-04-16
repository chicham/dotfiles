return {
  'rbong/vim-flog',
  lazy = true,
  cmd = { 'Flog', 'Flogsplit', 'Floggit' },
  dependencies = {
    'tpope/vim-fugitive',
  },
  keys = {
    { '<leader>gl', ':Flog<CR>', desc = 'View Git log' },
    { '<leader>gg', ':Floggit<CR>', desc = 'Open status Windows' },
  },
}
