return {
  "https://github.com/folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = function()
    return {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next Todo",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Prev Todo",
      },
      { "<leader>tc", ":<C-u>TodoTelescope<cr>", desc = "Telescope todo" },
    }
  end,
}
