return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    vim.keymap.set("n", "<leader>tt", "<cmd>TroubleToggle document_diagnostics<cr>", { silent = true, noremap = true })
    vim.keymap.set("n", "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { silent = true, noremap = true })
    vim.keymap.set("n", "<leader>tl", "<cmd>TroubleToggle loclist<cr>", { silent = true, noremap = true })
    vim.keymap.set("n", "<leader>tq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true })
    vim.keymap.set("n", "tr", "<cmd>TroubleToggle lsp_references<cr>", { silent = true, noremap = true })
    local trouble = require("trouble.providers.telescope")
    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<c-t>"] = trouble.open_with_trouble,
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
          n = {
            ["<c-t>"] = trouble.open_with_trouble,
          },
        },
      },
    })
    require("trouble").setup({
      use_diagnostic_signs = true,
      mode = "document_diagnostics",
    })
  end,
}
