-- Subword-aware w/e/b/ge motions (camelCase, snake_case, kebab). Same author as
-- nvim-various-textobjs / nvim-origami. Complements — does NOT replace — the
-- subword *text objects* az/iz: spider gives you `w`-style *motions* (cw, dw on
-- a subword), the text objects give you `ciz`/`diz` on the subword you're on.
return {
  'chrisgrieser/nvim-spider',
  keys = {
    { 'w', "<cmd>lua require('spider').motion('w')<CR>", mode = { 'n', 'o', 'x' }, desc = 'Spider w' },
    { 'e', "<cmd>lua require('spider').motion('e')<CR>", mode = { 'n', 'o', 'x' }, desc = 'Spider e' },
    { 'b', "<cmd>lua require('spider').motion('b')<CR>", mode = { 'n', 'o', 'x' }, desc = 'Spider b' },
    { 'ge', "<cmd>lua require('spider').motion('ge')<CR>", mode = { 'n', 'o', 'x' }, desc = 'Spider ge' },
  },
  opts = {
    -- Stop w/e/b at subword boundaries (camelCase, snake_case, kebab). This is
    -- spider's default, set explicitly here so the intent is obvious.
    subwordMovement = true,
    -- Keep the FAST traversal: skip punctuation that's attached to a word (`:`,
    -- `(`, `"` in `foo:find("a")`), so w/e/b move word-to-word with few stops.
    -- To land on an arbitrary special character, use `f<char>`/`t<char>` -- word
    -- motions are the wrong tool for that (they never land mid-cluster anyway).
    skipInsignificantPunctuation = true,
    -- ...but treat brackets as their own stop so `w` lands on `(` in e.g.
    -- `def infonce():`. overrideDefault=false ADDS to the default patterns.
    customPatterns = {
      patterns = { '[%(%)%[%]{}]+' },
      overrideDefault = false,
    },
  },
}
