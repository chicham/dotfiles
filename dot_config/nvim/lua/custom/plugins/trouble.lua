-- COMMENTED OUT: Trouble.nvim configuration (replaced by fzf-lua)
-- To revert, uncomment the configuration below and remove the fzf-lua alternatives

--[[
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
--]]

-- Disabled: use fzf-lua for diagnostics and TODO searching instead
return {}
