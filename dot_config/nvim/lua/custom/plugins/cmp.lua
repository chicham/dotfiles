return {
  -- Autocompletion
  "hrsh7th/nvim-cmp",
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",

    -- Adds LSP completion capabilities
    "hrsh7th/cmp-nvim-lsp",

    -- Adds a number of user-friendly snippets
    "rafamadriz/friendly-snippets",
  },
  config = function()
    require("cmp").setup({
      sources = {
        { name = "nvim_lsp" },
        { name = "treesitter" },
        { name = "luasnip" },
        { name = "path" },
        { name = "orgmode" },
        { name = "otter" },
      },
      view = {
        docs = {
          auto_open = false,
        },
      },
      experimental = {
        ghost_text = true,
      },
    })
  end,
}
