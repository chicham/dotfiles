-- Makes `.` repeat mappings that opt in by calling `repeat#set`. leap,
-- LuaSnip, orgmode and vim-matchup all call it, each behind a pcall, so the
-- plugin has to be on the runtimepath before any of them run -- which is why
-- it stays eager rather than hanging off one consumer's trigger. No
-- configuration and no keymaps of its own.
return {
  "tpope/vim-repeat",
}
