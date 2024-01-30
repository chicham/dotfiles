return {
  "https://github.com/akinsho/git-conflict.nvim",
  opts = {
    default_mappings = false,
  },
  keys = {
    { "<leader>co", "<Plug>(git-conflict-ours)" },
    { "<leader>ct", "<Plug>(git-conflict-theirs)" },
    { "<leader>cb", "<Plug>(git-conflict-both)" },
    { "<leader>c0", "<Plug>(git-conflict-none)" },
    { "[x", "<Plug>(git-conflict-prev-conflict)" },
    { "]x", "<Plug>(git-conflict-next-conflict)" },
  },
}
