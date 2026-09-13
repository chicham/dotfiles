return {
  "tummetott/unimpaired.nvim",
  opts = {
    -- Disable arg ([a ]a [A ]A) and file ([f ]f) nav: those keys are
    -- owned by nvim-treesitter-textobjects @parameter / @function moves.
    -- Buffer (]b), loclist (]l), quickfix (]q), tab (]t), toggles (yo*)
    -- all stay on unimpaired.
    keymaps = {
      previous = false,
      next = false,
      first = false,
      last = false,
      previous_file = false,
      next_file = false,
    },
  },
}
