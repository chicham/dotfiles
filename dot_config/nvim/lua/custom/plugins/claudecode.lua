-- claudecode.nvim: Claude Code CLI running inside nvim, over the same
-- WebSocket protocol as the official VS Code/JetBrains extensions.
--
-- Two-way: nvim pushes file/selection context as @-mentions, and Claude pulls
-- editor state (LSP diagnostics, open buffers, current selection) through the
-- protocol's tool calls. Edits Claude proposes arrive as native diff buffers.
--
-- The CLI decides where diffs render, not this plugin: a session connected to
-- an IDE pops a blocking diff per edit unless its own `/config` sets the diff
-- tool to `terminal`. Set that once per session when reviewing at commit
-- checkpoints rather than per edit.
--
-- One Claude session per jj workspace. Open nvim at the workspace root so the
-- spawned CLI inherits that cwd -- the same root `vim.fs.root(0, {'.jj'})`
-- resolves for `.review-comments.md`. Two sessions snapshotting one working
-- copy is what makes a workspace go stale.
return {
  "coder/claudecode.nvim",
  opts = {
    terminal = {
      -- snacks is eager here, and `Snacks.terminal` is a library module that
      -- needs no `opts` entry of its own, so the provider's availability test
      -- (`Snacks.terminal ~= nil`) always passes. It gives the CLI a real
      -- window with position and size honoured, which the built-in provider
      -- does not. The "external"/"none" providers are the ones to avoid: they
      -- leave nothing for `send_to_terminal` to type into.
      provider = "snacks",
    },
  },
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    {
      "<leader>ar",
      function()
        local root = vim.fs.root(0, { ".jj", ".git" }) or vim.fn.getcwd()
        local path = root .. "/.review-comments.md"
        if vim.fn.filereadable(path) == 0 then
          vim.notify("No review comments at " .. path, vim.log.levels.WARN)
          return
        end
        -- Send the path, not the contents: send_to_terminal types into
        -- the pane, so a multi-line paste would submit line by line.
        require("claudecode.terminal").send_to_terminal(
          "Review comments are ready in " .. path .. " -- read it and address the ISSUE and SUGGESTION entries.",
          { submit = true }
        )
      end,
      desc = "Send review comments",
    },
  },
}
