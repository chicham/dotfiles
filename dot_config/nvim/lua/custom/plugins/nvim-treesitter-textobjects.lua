return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  config = function()
    require("nvim-treesitter.configs").setup({
      textobjects = {
        select = {
          enable = true,
          lookhahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["a,"] = "@parameter.outer",
            ["i,"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["a#"] = "@comment.outer",
            ["i#"] = "@comment.inner",
            ["ik"] = "@assignment.lhs",
            ["ak"] = "@assignment.inner",
            ["iv"] = "@assignment.rhs",
            ["av"] = "@assignment.outer",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]]"] = { query = { "@class.outer", "@function.outer" } },
            -- ["]]"] = {query = {"@class.outer","@function.outer", "@loop.outer" , "@conditional.outer", "@scope.outer"} },
          },
          goto_previous_start = {
            ["[["] = { query = { "@class.outer", "@function.outer" } },
            -- ["[["] = {query = {"@class.outer","@function.outer", "@loop.outer" , "@conditional.outer", "@scope.outer"} },
          },
        },
        lsp_interop = {
          enable = true,
          border = "none",
          peek_definition_code = {
            ["<leader>df"] = "@function.outer",
            ["<leader>dc"] = "@class.outer",
          },
        },
      },
    })
  end,
}
