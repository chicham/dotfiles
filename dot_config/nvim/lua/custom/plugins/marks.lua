return {
  "chentoast/marks.nvim",
  -- Marks only exist against a file, so there is nothing to sign or preview
  -- until one is open.
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    default_mappings = true, -- Enable default mappings
    signs = true, -- Enable signs for marks
    mappings = {
      set_next = "m.", -- Set the next mark
      preview = "gm", -- Preview marks
    },
  },
}
