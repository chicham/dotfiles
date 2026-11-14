-- jj.nvim: drives Jujutsu from nvim -- log browsing on a live-editable revset,
-- revision and range diffs, a status picker, conflict resolution.
--
-- Review runs through difftastic.nvim (<leader>jd, <leader>jr); comments are
-- placed in its diff buffer, see quickfix-review.lua.
return {
  "NicolasGB/jj.nvim",
  version = "*",
  cmd = { "J", "Jdiff", "Jvdiff", "Jhdiff", "Jbrowse", "Jread", "Jedit" },
  -- <leader>j mirrors the shape of the CLI: what am I on, what changed,
  -- what is the graph, and the review that reads all three. Everything
  -- that rewrites history stays behind :J, where the subcommand has to
  -- be typed out.
  keys = {
    { "<leader>j", nil, desc = "Jujutsu" },
    { "<leader>js", "<cmd>J status<cr>", desc = "Status" },
    { "<leader>jl", "<cmd>J log<cr>", desc = "Log" },
    { "<leader>jd", "<cmd>Difft<cr>", desc = "Diff working copy (difftastic)" },
    { "<leader>jr", "<cmd>Difft chain(@)<cr>", desc = "Review this chain (difftastic)" },
    { "<leader>jb", "<cmd>Jbrowse<cr>", mode = { "n", "x" }, desc = "Open on remote" },
  },
  config = function()
    require("jj").setup({})
  end,
}
