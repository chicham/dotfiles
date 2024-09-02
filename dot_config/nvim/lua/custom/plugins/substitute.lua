return {
  'gbprod/substitute.nvim',
  lazy = true,

  opts = {
    yank_substituted_text = true,
    range = {
      prefix = 'S',
    },
  },
  -- Define key mappings with descriptions
  keys = {
    -- Substitute mappings
    {
      'gx',
      function()
        require('substitute').operator()
      end,
      { noremap = true, desc = 'Substitute (operator)' },
    },
    {
      'gxx',
      function()
        require('substitute').line()
      end,
      { noremap = true, desc = 'Substitute line' },
    },
    {
      'gX',
      function()
        require('substitute').eol()
      end,
      { noremap = true, desc = 'Substitute to end of line' },
    },
    {
      'gx',
      function()
        require('substitute').visual()
      end,
      { noremap = true, mode = 'x', desc = 'Substitute (visual)' },
    },

    -- Exchange mappings
    {
      'cx',
      function()
        require('substitute.exchange').operator()
      end,
      { noremap = true, desc = 'Exchange (operator)' },
    },
    {
      'cxx',
      function()
        require('substitute.exchange').line()
      end,
      { noremap = true, desc = 'Exchange line' },
    },
    {
      'X',
      function()
        require('substitute.exchange').visual()
      end,
      { noremap = true, mode = 'x', desc = 'Exchange (visual)' },
    },
  },
}
