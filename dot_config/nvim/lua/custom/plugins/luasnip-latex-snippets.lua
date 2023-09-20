return {
  "iurimateus/luasnip-latex-snippets.nvim",
  -- replace "lervag/vimtex" with "nvim-treesitter/nvim-treesitter" if you're
  -- using treesitter.
  requires = { "L3MON4D3/LuaSnip", "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("luasnip-latex-snippets").setup({ use_treesitter = true })
  end,
  -- treesitter is required for markdown
  ft = { "tex", "markdown" },
}
