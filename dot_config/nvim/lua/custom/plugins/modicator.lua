return {
  "mawkler/modicator.nvim",
  event = "ModeChanged",
  opts = {
    -- cursorline, number and termguicolors are what modicator needs, and
    -- config/options.lua already sets all three; this warns if something
    -- turns one back off.
    show_warnings = true,
    highlights = {
      defaults = {
        bold = true,
      },
      use_cursorline_background = false,
    },
  },
}
