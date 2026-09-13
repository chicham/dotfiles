return {
  "julienvincent/hunk.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  -- Only ever needed when jj launches nvim as the diff-editor, which runs
  -- `:DiffEditor $left $right $output`. Note the global jj `diff-editor` is
  -- `oyui`, so this is reached only from repos whose own config.toml overrides
  -- it to the nvim invocation above. Loading on that command means zero cost in
  -- normal editing sessions and nui.nvim is never pulled in unless you are
  -- actually resolving a diff.
  cmd = { "DiffEditor" },
  config = function()
    require("hunk").setup()
  end,
}
