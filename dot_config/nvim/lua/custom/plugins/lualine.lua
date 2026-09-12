return {

  "nvim-lualine/lualine.nvim",

  -- Load after UI is ready for better startup time
  event = "VeryLazy",

  dependencies = { "SmiteshP/nvim-navic" },

  -- Use the `setup` function for configuration
  opts = {
    icons_enabled = true,
    theme = "catppuccin",
    component_separators = "|",
    section_separators = "",
    extensions = { "quickfix", "lazy", "mason", "nvim-dap-ui", "oil", "trouble" },
    -- Mouseless breadcrumb in the statusline (module > class > function), driven
    -- by nvim-navic (pure LSP). The component renders empty until an LSP with
    -- documentSymbol attaches, so non-code buffers stay blank. Shares the
    -- stretchy lualine_c section with the filename; long breadcrumbs truncate.
    sections = {
      lualine_c = {
        "filename",
        { "navic", navic_opts = nil },
      },
    },
  },
}
