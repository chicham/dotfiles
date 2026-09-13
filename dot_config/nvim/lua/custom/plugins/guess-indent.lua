-- Detects tabstop and shiftwidth from the file being edited, so the values in
-- config/options.lua act as the fallback rather than the rule.
--
-- `opts` is what makes that happen: lazy.nvim only calls a plugin's `setup()`
-- for a spec that carries `opts` or `config`, and guess-indent installs its
-- detection autocommand from inside `setup()`. There is no `plugin/` directory
-- to run it otherwise, so a bare spec leaves the plugin loaded and inert.
return {
  "NMAC427/guess-indent.nvim",
  -- setup() registers the BufReadPost/BufNewFile handler itself, so the plugin
  -- only has to exist by the time the first buffer is read.
  event = { "BufReadPost", "BufNewFile" },
  opts = {},
}
