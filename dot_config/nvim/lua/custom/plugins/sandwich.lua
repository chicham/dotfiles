return {
  'machakann/vim-sandwich',
  opts = {
    rtp = 'macros',
  },
  config = function()
    vim.cmd [[ runtime macros/sandwich/keymap/surround.vim ]]
  end,
}
