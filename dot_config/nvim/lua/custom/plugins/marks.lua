return {
  'chentoast/marks.nvim',
  opts = {
    default_mappings = true, -- Enable default mappings
    signs = true, -- Enable signs for marks
    mappings = {
      set_next = 'm.', -- Set the next mark
      preview = 'gm', -- Preview marks
    },
  },
}
