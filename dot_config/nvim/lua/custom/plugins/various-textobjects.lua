-- `keys` is a plain list, not a function: lazy.nvim evaluates a `keys`
-- function while normalising the spec, inside lazy.setup(), so a `require` in
-- its body loads the plugin at startup and defeats the trigger it is meant to
-- declare. The require belongs inside each right-hand side, which runs only
-- once the key is pressed.
local function textobj(fn, scope)
  return function()
    require("various-textobjs")[fn](scope)
  end
end

return {
  "chrisgrieser/nvim-various-textobjs",
  opts = {
    keymaps = {
      useDefaults = false,
    },
  },
  keys = {
    -- Line-wise text objects
    { "al", textobj("lineCharacterwise", "outer"), mode = { "o", "x" }, desc = "line (outer)" },
    { "il", textobj("lineCharacterwise", "inner"), mode = { "o", "x" }, desc = "line (inner)" },

    -- NB: ai/ii (indentation) live on mini.indentscope now, so its scope
    -- highlight and the ii/ai text objects are computed identically -- see
    -- the mini.indentscope spec in lua/custom/plugins/mini.lua.

    -- Subword text objects
    { "az", textobj("subword", "outer"), mode = { "o", "x" }, desc = "subword (outer)" },
    { "iz", textobj("subword", "inner"), mode = { "o", "x" }, desc = "subword (inner)" },

    -- Chain member text objects
    { "am", textobj("chainMember", "outer"), mode = { "o", "x" }, desc = "chain member (outer)" },
    { "im", textobj("chainMember", "inner"), mode = { "o", "x" }, desc = "chain member (inner)" },

    -- Value text objects (for key-value pairs/assignments)
    { "av", textobj("value", "outer"), mode = { "o", "x" }, desc = "value (outer)" },
    { "iv", textobj("value", "inner"), mode = { "o", "x" }, desc = "value (inner)" },

    -- Key text objects (for key-value pairs/assignments)
    { "ak", textobj("key", "outer"), mode = { "o", "x" }, desc = "key (outer)" },
    { "ik", textobj("key", "inner"), mode = { "o", "x" }, desc = "key (inner)" },

    -- NB: ib/ab (any bracket / any quote) are NOT here. anyBracket uses
    -- lexical %b() scanning, which jumps to a sibling bracket when the cursor
    -- sits inside nested brackets, and cannot understand Python's """ """ /
    -- f-strings. They are a treesitter-based object instead -- see
    -- lua/custom/anyblock.lua, started by custom.anyblock.setup().
    { "iq", textobj("anyQuote", "inner"), mode = { "o", "x" }, desc = "quote (inner)" },
    { "aq", textobj("anyQuote", "outer"), mode = { "o", "x" }, desc = "quote (outer)" },
  },
}
