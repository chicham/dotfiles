return {
  "folke/todo-comments.nvim",
  dependencies = {"nvim-lua/plenary.nvim"},
  config = function ()
    vim.keymap.set("n", "<leader>ft", ":<C-u>TodoTelescope<cr>")
    require("todo-comments").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      highlight = {
        pattern = [[(KEYWORDS)\s*(\([^\)]*\))?:]],
        keyword = "bg",
        after = "",
      },
    }
  end

}
