return {
  "tpope/vim-fugitive",
  config = function(_, opts)
    vim.keymap.set("n", "<leader>gg", ":<C-u>0Git<cr>", { silent = true })
    vim.keymap.set("n", "<leader>gw", ":<C-u>Gwrite<cr>")
    vim.keymap.set("n", "<leader>gW", ":<C-u>Gwrite!<cr>")
    vim.keymap.set("n", "<leader>g+", ":<C-u>Git stash<cr>:e<cr>")
    vim.keymap.set("n", "<leader>g-", ":<C-u>Git stash pop<cr>:e<cr>")
    vim.keymap.set("n", "<leader>go", ":execute line('.') . ',GBrowse'<cr>", { silent = true })
    vim.keymap.set("n", "<leader>gv", ":<C-u>Gvdiff<cr>")
    vim.keymap.set("n", "<leader>gt", require("telescope.builtin").git_stash)
    vim.keymap.set("n", "<leader>fg", require("telescope.builtin").grep_string, { desc = "Search current Word" })
  end,
}
