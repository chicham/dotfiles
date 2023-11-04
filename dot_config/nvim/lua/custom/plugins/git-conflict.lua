return {
  "https://github.com/akinsho/git-conflict.nvim",
  config = function()
    require("git-conflict").setup({
      default_mappings = false,
    })
    vim.keymap.set("n", "<leader>co", "<Plug>(git-conflict-ours)")
    vim.keymap.set("n", "<leader>ct", "<Plug>(git-conflict-theirs)")
    vim.keymap.set("n", "<leader>cb", "<Plug>(git-conflict-both)")
    vim.keymap.set("n", "<leader>c0", "<Plug>(git-conflict-none)")
    vim.keymap.set("n", "]x", "<Plug>(git-conflict-prev-conflict)")
    vim.keymap.set("n", "[x", "<Plug>(git-conflict-next-conflict)")
  end,
}
