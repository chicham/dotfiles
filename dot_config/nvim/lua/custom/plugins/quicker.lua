return {
  'stevearc/quicker.nvim',
  event = 'FileType qf',
  ---@module "quicker"
  ---@type quicker.SetupOptions
  keys = function()
    local quicker = require 'quicker'
    return {
      { '<leader>qq', quicker.toggle, desc = 'Toggle quickfix' },
      {
        '<leader>ql',
        function()
          quicker.toggle { loclist = true }
        end,
        desc = 'Toggle loclist',
      },
    }
  end,
  config = function()
    local quicker = require 'quicker'
    return {
      keys = {
        {
          '>',
          function()
            quicker.expand { before = 2, after = 2, add_to_existing = true }
          end,
          desc = 'Expand quickfix context',
        },
        {
          '<',
          function()
            quicker.collapse()
          end,
          desc = 'Collapse quickfix context',
        },
      },
    }
  end,
}
