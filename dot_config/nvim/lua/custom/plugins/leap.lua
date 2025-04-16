return {
  'ggandor/leap.nvim',

  -- Key mappings with descriptions
  keys = {
    { ',', '<Plug>(leap-forward-to)', mode = { 'n', 'o', 'x' }, desc = 'Leap forward' },
    { ';', '<Plug>(leap-backward-to)', mode = { 'n', 'o', 'x' }, desc = 'Leap backward' },
    { 'g,', '<Plug>(leap-from-window)', mode = { 'n', 'o', 'x' }, desc = 'Leap from window' },
  },

  -- Optimized labels for bépo layout, focusing on single characters
  opts = {
    safe_labels = {}, -- Empty to allow all labels
    labels = {
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
    },
  },
}
