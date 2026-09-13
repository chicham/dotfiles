-- Saves the window and buffer layout on exit and restores it on demand, keyed
-- by the working directory.
--
-- The plugin also appends a git branch to that key, but only when
-- `git branch --show-current` answers. A colocated jj repo keeps git's HEAD
-- detached, so it answers with nothing and the key stays the directory alone --
-- one session per checkout, which is what the workspace-per-change workflow
-- wants anyway.
--
-- Chosen over mini.sessions despite the mini-first rule: mini.sessions has "no
-- automated new session creation" (mini/sessions.lua:20) -- a session exists
-- only once `MiniSessions.write()` names one, and its per-directory variant is
-- a `Session.vim` written into the project itself. Nothing here is named or
-- committed: the session appears on quit and lives in stdpath("state").
--
-- Loading on BufReadPre, not on the keys below, is what makes it work at all --
-- the save is a VimLeavePre autocmd, so the plugin has to be loaded before the
-- session it saves. `need = 1` (the default) means a Neovim opened on no file
-- never overwrites a real session.
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  keys = {
    {
      "<leader>Ss",
      function()
        require("persistence").load()
      end,
      desc = "[S]ession for this directory",
    },
    {
      "<leader>Sl",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "[S]ession, most recent anywhere",
    },
    {
      "<leader>Sf",
      function()
        require("persistence").select()
      end,
      desc = "[S]ession, pick from a list",
    },
    {
      "<leader>Sd",
      function()
        require("persistence").stop()
      end,
      desc = "[S]top saving this session",
    },
  },
}
