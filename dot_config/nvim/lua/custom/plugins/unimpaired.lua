return {
  "tummetott/unimpaired.nvim",
  opts = {
    -- Disable arg ([a ]a [A ]A) and file ([f ]f) nav: those keys are
    -- owned by nvim-treesitter-textobjects @parameter / @function moves.
    -- Disable buffer nav ([b ]b) too: vcsigns walks the diff base there, and
    -- buffers are on <S-h> / <S-l> in config/keymaps.lua. Turning it off here
    -- rather than letting vcsigns win by load order makes the ownership
    -- explicit and keeps [B / ]B (first/last buffer) working.
    -- Loclist ([l ]l), quickfix ([q ]q), tags ([t ]t) and the toggles (yo*)
    -- all stay on unimpaired.
    keymaps = {
      previous = false,
      next = false,
      first = false,
      last = false,
      previous_file = false,
      next_file = false,
      bprevious = false,
      bnext = false,
    },
  },
}
