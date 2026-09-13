-- A quickfix window that reads like a buffer: aligned columns, a diff-style
-- sign column, and `>` / `<` to widen or narrow the surrounding context lines
-- without leaving the list. The quickfix list is the review surface here --
-- quickfix-review keeps its comments in it and jj.lua's `:JjReview` builds its
-- file list from it -- so it is worth having it legible.
return {
  "stevearc/quicker.nvim",
  event = "FileType qf",
  keys = {
    {
      "<leader>qq",
      function()
        require("quicker").toggle()
      end,
      desc = "Toggle quickfix",
    },
    {
      "<leader>ql",
      function()
        require("quicker").toggle({ loclist = true })
      end,
      desc = "Toggle loclist",
    },
  },
  opts = {
    keys = {
      {
        ">",
        function()
          require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
        end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function()
          require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
      },
    },
  },
}
