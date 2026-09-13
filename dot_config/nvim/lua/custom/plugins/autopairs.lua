return {
  "windwp/nvim-autopairs",
  -- Every mapping it installs is an Insert-mode one.
  event = "InsertEnter",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-autopairs").setup({
      -- ignored_next_char = '[%w%.]',
      check_ts = true,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
        java = false,
      },
    })
  end,
}
