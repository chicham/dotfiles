return {
  'lukas-reineke/indent-blankline.nvim',

  main = 'ibl',
  dependencies = {
    'https://github.com/HiPhish/rainbow-delimiters.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  event = 'BufEnter',

  -- Define highlight groups within the plugin configuration
  config = function()
    local hooks = require 'ibl.hooks'
    local highlight = {
      'RainbowDelimiterRed',
      'RainbowDelimiterYellow',
      'RainbowDelimiterBlue',
      'RainbowDelimiterOrange',
      'RainbowDelimiterGreen',
      'RainbowDelimiterViolet',
      'RainbowDelimiterCyan',
    }

    require('ibl').setup {
      indent = {
        char = '┊',
      },
      scope = {
        show_start = false,
        show_end = false,
        highlight = highlight,
      },
    }

    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
  end,
}
