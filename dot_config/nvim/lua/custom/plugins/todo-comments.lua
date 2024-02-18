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
      { "<leader>ft", "<Cmd>exe ':TodoLocList cwd=' .. fnameescape(expand('%:p'))<CR>", desc = "Telescope todo" },
      { "<leader>fT", "<Cmd>TodoTelescope<CR>", desc = "Telescope todo" },
    }
  end,
}
