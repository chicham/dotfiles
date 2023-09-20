return {
  "https://github.com/chentoast/marks.nvim",
  config = function()
    require("marks").setup({
      default_mappings = true,
      signs = true,
      mappings = {
        set_next = "m.",
        preview = "gm",
      },
    })
  end,
}
