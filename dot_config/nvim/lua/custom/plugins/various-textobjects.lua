return {
  "chrisgrieser/nvim-various-textobjs",
  opts = {
    keymaps = {
      useDefaults = false,
    },
  },
  keys = function()
    local vt = require("various-textobjs")
    return {
      -- Line-wise text objects
      {
        "al",
        function()
          vt.lineCharacterwise("outer")
        end,
        mode = { "o", "x" },
      },
      {
        "il",
        function()
          vt.lineCharacterwise("inner")
        end,
        mode = { "o", "x" },
      },

      -- NB: ai/ii (indentation) live on mini.indentscope now, so its scope
      -- highlight and the ii/ai text objects are computed identically — see
      -- the mini.indentscope spec in lua/custom/plugins/mini.lua.

      -- Subword text objects
      {
        "az",
        function()
          vt.subword("outer")
        end,
        mode = { "o", "x" },
      },
      {
        "iz",
        function()
          vt.subword("inner")
        end,
        mode = { "o", "x" },
      },
      -- Chain member text objects
      {
        "am",
        function()
          vt.chainMember("outer")
        end,
        mode = { "o", "x" },
      },
      {
        "im",
        function()
          vt.chainMember("inner")
        end,
        mode = { "o", "x" },
      },
      -- Value text objects (for key-value pairs/assignments)
      {
        "av",
        function()
          vt.value("outer")
        end,
        mode = { "o", "x" },
      },
      {
        "iv",
        function()
          vt.value("inner")
        end,
        mode = { "o", "x" },
      },
      -- Key text objects (for key-value pairs/assignments)
      {
        "ak",
        function()
          vt.key("outer")
        end,
        mode = { "o", "x" },
      },
      {
        "ik",
        function()
          vt.key("inner")
        end,
        mode = { "o", "x" },
      },

      -- NB: ib/ab (any bracket / any quote) are NOT here. anyBracket uses
      -- lexical %b() scanning, which jumps to a sibling bracket when the cursor
      -- sits inside nested brackets, and cannot understand Python's """ """ /
      -- f-strings. They are now a treesitter-based object — see
      -- lua/custom/anyblock.lua (wired in init.lua).
      {
        "iq",
        function()
          vt.anyQuote("inner")
        end,
        mode = { "o", "x" },
      },
      {
        "aq",
        function()
          vt.anyQuote("outer")
        end,
        mode = { "o", "x" },
      },
    }
  end,
}
