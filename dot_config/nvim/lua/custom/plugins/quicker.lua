return {
  'stevearc/quicker.nvim',
  event = 'FileType qf',
  keys = {
    {
      '<leader>qq',
      function()
        require('quicker').toggle()
      end,
      desc = 'Toggle quickfix'
    },
    {
      '<leader>ql',
      function()
        require('quicker').toggle { loclist = true }
      end,
      desc = 'Toggle loclist',
    },
  },
  opts = {
    keys = {
      {
        '>',
        function()
          require('quicker').expand { before = 2, after = 2, add_to_existing = true }
        end,
        desc = 'Expand quickfix context',
      },
      {
        '<',
        function()
          require('quicker').collapse()
        end,
        desc = 'Collapse quickfix context',
      },
    },
  },
}
