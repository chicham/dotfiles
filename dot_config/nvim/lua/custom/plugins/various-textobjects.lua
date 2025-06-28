return {
  'chrisgrieser/nvim-various-textobjs',
  opts = {
    keymaps = {
      useDefaults = false,
    },
  },
  keys = function()
    local vt = require 'various-textobjs'
    return {
      -- Line-wise text objects
      {
        'al',
        function()
          vt.lineCharacterwise 'outer'
        end,
        mode = { 'o', 'x' },
      },
      {
        'il',
        function()
          vt.lineCharacterwise 'inner'
        end,
        mode = { 'o', 'x' },
      },

      -- Subword text objects
      {
        'az',
        function()
          vt.subword 'outer'
        end,
        mode = { 'o', 'x' },
      },
      {
        'iz',
        function()
          vt.subword 'inner'
        end,
        mode = { 'o', 'x' },
      },
      -- Chain member text objects
      {
        'am',
        function()
          vt.chainMember 'outer'
        end,
        mode = { 'o', 'x' },
      },
      {
        'im',
        function()
          vt.chainMember 'inner'
        end,
        mode = { 'o', 'x' },
      },
      -- Value text objects (for key-value pairs/assignments)
      {
        'av',
        function()
          vt.value 'outer'
        end,
        mode = { 'o', 'x' },
      },
      {
        'iv',
        function()
          vt.value 'inner'
        end,
        mode = { 'o', 'x' },
      },
      -- Key text objects (for key-value pairs/assignments)
      {
        'ak',
        function()
          vt.key 'outer'
        end,
        mode = { 'o', 'x' },
      },
      {
        'ik',
        function()
          vt.key 'inner'
        end,
        mode = { 'o', 'x' },
      },

    }
  end,
}
