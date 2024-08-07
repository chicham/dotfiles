return {
  "windwp/nvim-autopairs",
  dependencies = { "hrsh7th/nvim-cmp", "nvim-treesitter/nvim-treesitter" },
  opts = function(_, opts)
    require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    return {
      disable_in_macro = true,
      enable_check_bracket_line = true, -- Don't add pairs if it already has a close pair in the same line
      ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
      check_ts = true, -- use treesitter to check for a pair.
      ts_config = {
        lua = { "string" }, -- it will not add pair on that treesitter node
        javascript = { "template_string" },
        java = false, -- don't check treesitter on java
      },
    }
  end,
}
