return {
  "https://github.com/sainnhe/gruvbox-material",
  dependencies = {
    "nvim-lualine/lualine.nvim",
  },
  config = function()
    vim.o.background = "dark"
    vim.g.gruvbox_material_background = "medium"
    vim.g.gruvbox_material_foreground = "material"
    vim.g.gruvbox_material_enable_bold = 1
    vim.g.gruvbox_material_better_performance = 1
    vim.g.gruvbox_material_diagnostic_line_highlight = 1
    vim.cmd.colorscheme("gruvbox-material")
    require("lualine").setup({
      options = {
        theme = "gruvbox-material",
      },
    })
  end,
}
