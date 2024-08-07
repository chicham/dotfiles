return {
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  "lewis6991/gitsigns.nvim",
  opts = {},
  keys = {
    {
      "]c",
      function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").next_hunk()
        end)
        return "<Ignore>"
      end,
      { expr = true },
    },
    {
      "[c",
      function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          require("gitsign").prev_hunk()
        end)
        return "<Ignore>"
      end,
      { expr = true },
    },
    { "<leader>gs", require("gitsigns").stage_hunk },
    { "<leader>gr", require("gitsigns").reset_hunk },
    { "<leader>gu", require("gitsigns").undo_stage_hunk },
    { "<leader>gS", require("gitsigns").stage_buffer },
    { "<leader>gp", require("gitsigns").preview_hunk },
    {
      "<leader>gB",
      function()
        require("gitsigns").blame_line({ full = true })
      end,
    },
    { "<leader>gb", require("gitsigns").toggle_current_line_blame },
    { "<leader>gd", require("gitsigns").diffthis },
    {
      "<leader>gD",
      function()
        require("gitsigns").diffthis("~")
      end,
    },
    { "ih", mode = { "o", "x" }, ":<C-U>Gitsigns select_hunk<CR>" },
  },
}
