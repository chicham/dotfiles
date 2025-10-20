return {
  'ggandor/leap.nvim',
  dependencies = { 'tpope/vim-repeat' },

  -- Key mappings with descriptions (updated to new API)
  keys = {
    { ',', '<Plug>(leap-forward)', mode = { 'n', 'x', 'o' }, desc = 'Leap forward' },
    { ';', '<Plug>(leap-backward)', mode = { 'n', 'x', 'o' }, desc = 'Leap backward' },
    { 'g,', '<Plug>(leap-from-window)', mode = { 'n', 'x', 'o' }, desc = 'Leap from window' },
    
    -- Remote operations (replaces telepath.nvim with leap's built-in remote)
    -- These mappings only work in operator-pending mode (after d, y, c, etc.)
    -- r - remote with restore (return to initial position): dr{leap}iw, yr{leap}ap
    { 'r', function()
      require('leap.remote').action {
        input = vim.fn.mode(true):match('o') and '' or 'v'
      }
    end, mode = { 'o' }, desc = 'Leap remote (restore)' },
    
    -- m - remote without restore (magnet - stay at target): dm{leap}i(, ym{leap}it
    { 'm', function()
      require('leap.remote').action {
        input = vim.fn.mode(true):match('o') and '' or 'v',
        restore = false,
      }
    end, mode = { 'o' }, desc = 'Leap remote (magnet)' },
    
    -- Treesitter node selection (visual/operator-pending mode)
    -- n - node selection: vnnn...y or yn{label}
    { 'n', function()
      require('leap.treesitter').select {
        opts = require('leap.user').with_traversal_keys('n', 'N')
      }
    end, mode = { 'x', 'o' }, desc = 'Leap treesitter node' },
  },

  config = function()
    local leap = require('leap')
    
    -- Optimized labels for bépo layout, focusing on single characters
    leap.opts.safe_labels = {} -- Empty to allow all labels
    leap.opts.labels = {
      's',
      't',
      'r',
      'n',
      'm', -- Home row and nearby
      'e',
      'i',
      'u',
      'a',
      'o', -- Vowels
      'v',
      'd',
      'l',
      'j',
      'p', -- Comfortable consonants
      'z',
      'b',
      'f',
      'g', -- Less frequent but accessible
    }
    
    -- Recommended tweaks: preview filter to reduce visual noise
    -- Exclude whitespace and the middle of alphabetic words from preview
    leap.opts.preview_filter = function(ch0, ch1, ch2)
      return not (
        ch1:match('%s')
        or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
      )
    end
    
    -- Define equivalence classes for brackets and quotes
    leap.opts.equivalence_classes = {
      ' \t\r\n', '([{', ')]}', '\'"`'
    }
    
    -- Use the traversal keys to repeat the previous motion
    require('leap.user').set_repeat_keys('<enter>', '<backspace>')
  end,
}
