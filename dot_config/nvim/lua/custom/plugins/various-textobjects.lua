return {
  'chrisgrieser/nvim-various-textobjs',
  opts = {
    useDefaultKeymaps = false,
  },
  keys = function()
    local vt = require 'various-textobjs'
    return {
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
      {
        'ai',
        function()
          vt.identation('outer', 'inner')
        end,
        mode = { 'o', 'x' },
      },
      {
        'ii',
        function()
          vt.indentation('inner', 'inner')
        end,
        mode = { 'o', 'x' },
      },
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
      {
        'aq',
        function()
          vt.pyTripleQuotes 'outer'
        end,
        mode = { 'o', 'x' },
      },
      {
        'im',
        function()
          vt.pyTripleQuotes 'inner'
        end,
        mode = { 'o', 'x' },
      },
    }
  end,
}