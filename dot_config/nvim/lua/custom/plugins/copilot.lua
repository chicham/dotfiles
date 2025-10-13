return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
        copilot_model = "gpt-4o-copilot",
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    event = "InsertEnter",
    config = function()
      require("copilot_cmp").setup()

      -- Extend existing cmp sources elegantly
      local cmp = require("cmp")
      cmp.setup({
        sources = cmp.config.sources(
          vim.list_extend(
            cmp.get_config().sources or {},
            {{ name = "copilot", priority = 900 }}
          )
        )
      })
    end,
  },
}
