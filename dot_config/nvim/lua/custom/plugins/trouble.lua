return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>tt",
      function()
        require("telescope.builtin").diagnostics({ bufnr = 0 })
      end,
      { desc = "Search Document [D]iagnostics" },
    },
    { "<leader>td", "<cmd>TroubleToggle document_diagnostics<cr>", { silent = true, noremap = true } },
    { "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { silent = true, noremap = true } },
    { "<leader>tl", "<cmd>TroubleToggle loclist<cr>", { silent = true, noremap = true } },
    { "<leader>tq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true } },
    { "<leader>tr", "<cmd>TroubleToggle lsp_references<cr>", { silent = true, noremap = true } },
  },
  config = function()
    local trouble = require("trouble.providers.telescope")
    require("trouble").setup({
      use_diagnostic_signs = true,
      mode = "document_diagnostics",
    })
  end,
}
