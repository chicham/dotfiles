-- GitHub issues and pull requests as ordinary buffers: `:Octo pr list`,
-- `:Octo pr edit <n>`. It is the review surface for a PR, the counterpart of
-- quickfix-review for a local diff, and the `local-review` workflow points at
-- one or the other depending on where the change lives.
--
-- `picker = "fzf-lua"` keeps octo's pickers on the same finder as the rest of
-- the config rather than pulling in telescope.
return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-mini/mini.icons",
    "ibhagwan/fzf-lua",
  },
  cmd = "Octo",
  opts = {
    picker = "fzf-lua",
  },
}
