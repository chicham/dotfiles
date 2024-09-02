return {

  'nvim-lualine/lualine.nvim',

  -- Use 'lazy = true' to load the plugin only when needed
  -- lazy = true,

  -- Specify dependencies explicitly for clarity
  dependencies = { 'sainnhe/gruvbox-material' },

  -- Use the `setup` function for configuration
  opts = {
    icons_enabled = true,
    theme = 'gruvbox-material',
    component_separators = '|',
    section_separators = '',
    extensions = { 'quickfix', 'fugitive', 'lazy', 'mason', 'nvim-dap-ui', 'oil', 'trouble' },
  },
}
