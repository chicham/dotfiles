return {
  'folke/trouble.nvim',
  opts = {},
  cmd = 'Trouble',
  keys = {
    {
      '<leader>tD',
      '<cmd>Trouble diagnostics toggle focus=true<cr>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<leader>td',
      '<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>tt',
      '<cmd>Trouble todo toggle focus=true filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>tT',
      '<cmd>Trouble todo<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
  },
}
