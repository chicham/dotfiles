return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "BufReadPost",
  config = function()
    require("treesitter-context").setup({
      enable = true,
      -- Deeply nested constructs -- a beamer frame holding columns holding a
      -- block holding an itemize -- stack one sticky line per level, and an
      -- unbounded context eats the top of the screen in exactly the files
      -- where knowing the enclosing scope matters most. Four is the depth past
      -- which the context costs more room than it repays.
      max_lines = 4,
      trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      multiline_threshold = 20, -- Maximum number of lines to show for a single context
      line_numbers = true,
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      multiwindow = false,
      zindex = 20, -- The Z-index of the context window
      mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
      separator = nil, -- Separator between context and content. Should be a single character string, like '-'.
    })
  end,
}
