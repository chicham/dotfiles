return {
  -- leap.nvim moved from GitHub to Codeberg
  url = 'https://codeberg.org/andyg/leap.nvim',
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

    -- Enhanced f/F/t/T (1-char search), replacing the unmaintained flit.nvim.
    -- Trigger-only entries: leap loads on first press, then config() below
    -- installs the real clever-f mappings and the press is replayed.
    { 'f', mode = { 'n', 'x', 'o' }, desc = 'Leap f (1-char)' },
    { 'F', mode = { 'n', 'x', 'o' }, desc = 'Leap F (1-char)' },
    { 't', mode = { 'n', 'x', 'o' }, desc = 'Leap t (1-char)' },
    { 'T', mode = { 'n', 'x', 'o' }, desc = 'Leap T (1-char)' },
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

    -- Enhanced f/F/t/T motions (1-character search), replacing flit.nvim.
    -- Canonical snippet from leap's README (:help leap-ft): inputlen = 1 forces
    -- a single-char target and (safe) autojump; f/F and t/T double as clever-f
    -- traversal keys (press f again to advance, F to go back), so ;/, stay free
    -- for leap-forward/backward.
    do
      local function ft(key_specific_args)
        require('leap').leap(
          vim.tbl_deep_extend('keep', key_specific_args, {
            inputlen = 1,
            inclusive = true,
            opts = {
              labels = '', -- force autojump
              safe_labels = vim.fn.mode(1):match('o') and '' or nil,
            },
          })
        )
      end

      local clever = require('leap.user').with_traversal_keys
      local clever_f, clever_t = clever('f', 'F'), clever('t', 'T')

      vim.keymap.set({ 'n', 'x', 'o' }, 'f', function() ft { opts = clever_f } end)
      vim.keymap.set({ 'n', 'x', 'o' }, 'F', function() ft { backward = true, opts = clever_f } end)
      vim.keymap.set({ 'n', 'x', 'o' }, 't', function() ft { offset = -1, opts = clever_t } end)
      vim.keymap.set({ 'n', 'x', 'o' }, 'T', function() ft { backward = true, offset = 1, opts = clever_t } end)
    end
  end,
}
