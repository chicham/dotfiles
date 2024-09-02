return {
  'https://github.com/stevearc/oil.nvim',

  -- Explicit dependencies for clarity
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  -- Use the `setup` function for configuration
  config = function()
    require('oil').setup()
  end,

  -- Key mappings with descriptions
  keys = {
    { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' },
  },
}
