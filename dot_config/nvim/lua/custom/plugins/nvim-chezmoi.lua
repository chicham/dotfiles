-- Editing support for the chezmoi source tree: :ChezmoiApply and friends, and
-- the buffer wiring that makes a `dot_`-prefixed source file behave like the
-- target it generates.
--
-- Distinct from chezmoi.vim (see chezmoi.lua), which only does filetype
-- detection and has to stay eager for that.

-- chezmoi's own `sourceDir`. Naming it here does two things: it is the pattern
-- the spec loads on, and passing it as `source_path` stops setup() from
-- shelling out to `chezmoi source-path` to discover what we already know.
local source_dir = (vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")) .. "/chezmoi"

return {
  "andre-kotake/nvim-chezmoi",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- Nothing it provides means anything outside the source tree, so opening a
  -- file there is the trigger; the commands cover reaching it from elsewhere.
  event = { { event = { "BufNewFile", "BufRead" }, pattern = source_dir .. "/*" } },
  -- ChezmoiFiles and ChezmoiManaged are deliberately absent: the plugin only
  -- defines them when telescope is loadable, and this config uses fzf-lua.
  -- Listing them would create stubs that load the plugin and then fail.
  cmd = {
    "ChezmoiApply",
    "ChezmoiDetectFiletype",
    "ChezmoiEdit",
    "ChezmoiExecuteTemplate",
  },
  -- `execute_template` is left at its defaults: it opens in a vsplit, so the
  -- floating-window options the plugin also accepts are never read.
  opts = {
    source_path = source_dir,
    edit = {
      apply_on_save = "never", -- Options: "auto", "confirm", "never"
    },
  },
}
