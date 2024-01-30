return {
  "joaomsa/telescope-orgmode.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-orgmode/orgmode",
  },
  config = function()
    require("telescope").load_extension("orgmode")
    vim.keymap.set(
      "n",
      "<leader>fo",
      require("telescope").extensions.orgmode.search_headings,
      { desc = "Find [C]ommands" }
    )
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = "org",
    --   group = vim.api.nvim_create_augroup("orgmode_telescope_nvim", { clear = true }),
    --   callback = function()
    --     vim.keymap.set("n", "<leader>or", require("telescope").extensions.orgmode.refile_heading, { desc = "Telescope refile_heading"})
    --   end,
    -- })
  end,
}
