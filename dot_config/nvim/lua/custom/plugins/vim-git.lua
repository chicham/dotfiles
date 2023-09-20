return {
  "https://github.com/tpope/vim-git",
  config = function()
    vim.keymap.set("n", "<leader>gbp", ":Pick<cr>", { silent = true })
    vim.keymap.set("n", "<leader>gbs", ":Squash<cr>", { silent = true })
    vim.keymap.set("n", "<leader>gbe", ":Edit<cr>", { silent = true })
    vim.keymap.set("n", "<leader>gbr", ":Reword<cr>", { silent = true })
    vim.keymap.set("n", "<leader>gbf", ":Fixup<cr>", { silent = true })
    vim.keymap.set("n", "<leader>gbd", ":Drop<cr>", { silent = true })
    vim.keymap.set("n", "<leader>gbb", ":Cycle<cr>", { silent = true })
  end,
}
