return {
  "stevearc/oil.nvim",
  -- Eager because oil is the file explorer: netrw is switched off in
  -- lazy.setup's disabled_plugins, and oil only takes over directory buffers
  -- (`nvim .`, `:e src/`) from setup() onward. Left lazy, opening a directory
  -- would land in an empty buffer with no browser at all.
  lazy = false,
  dependencies = { "nvim-mini/mini.icons" },
  opts = {
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-v>"] = "actions.select_vsplit",
      ["<C-s>"] = "actions.select_split",
      ["<C-r>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["g."] = "actions.toggle_hidden",
    },
  },
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
  },
}
