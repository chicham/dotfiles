return {
  'sondalex/mystnb.nvim',
  ft = { 'markdown', 'myst' },
  config = function()
    require('mystnb').setup()
  end,
}
