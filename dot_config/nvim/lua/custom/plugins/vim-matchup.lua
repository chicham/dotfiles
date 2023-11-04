return {
  "https://github.com/andymass/vim-matchup",
  config = function()
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
    require("nvim-treesitter.configs").setup({
      matchup = {
        enable = true, -- mandatory, false will disable the whole extension
        disable_virtual_text = true,
      },
    })
  end,
}
