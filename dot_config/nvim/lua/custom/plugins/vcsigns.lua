-- vcsigns.nvim: inline VCS signs + hunk navigation/undo, git and jj alike.
-- It resolves `.jj` before `.git`, which is what makes it work inside a
-- secondary jj workspace: `.workspaces/<name>` carries no `.git` of its own,
-- so a plugin that resolves through `git rev-parse` either finds no repo at
-- all or, under a colocated repo, resolves the *parent* toplevel and reports
-- every file there as ignored. Signs behave identically in the main checkout
-- and in a workspace.
--
-- Hunk navigation uses ]h / [h because ]c / [c are taken by the treesitter
-- class-motion mappings in treesitter.lua (the upstream README binds ]c / [c).
return {
  "algmyr/vcsigns.nvim",
  dependencies = { "algmyr/vclib.nvim", "lewis6991/async.nvim" },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("vcsigns").setup({
      -- Offset 0 is the correct base for both backends: the git adapter
      -- diffs against `HEAD~0`, and the jj adapter reverse-applies `@`'s
      -- own diff, yielding `@-`. So signs always show what the current
      -- change introduces -- uncommitted work under git, the contents of
      -- `@` under jj. ]b / [b walk the base further back on demand.
      target_commit = 0,
      signs = {
        text = {
          add = "┃",
          change = "┃",
          delete_below = "_",
          delete_above = "‾",
          delete_above_below = "~",
        },
      },
    })

    local actions = require("vcsigns.actions")
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { desc = desc })
    end

    -- Navigation (respects diff mode)
    map("n", "]h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        actions.hunk_next(0, vim.v.count1)
      end
    end, "Next VCS hunk")
    map("n", "[h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        actions.hunk_prev(0, vim.v.count1)
      end
    end, "Previous VCS hunk")

    -- Hunk actions. No staging equivalent by design: jj snapshots the
    -- working tree and has no index to stage into.
    map("n", "<leader>hr", function()
      actions.hunk_undo(0, { vim.fn.line("."), vim.fn.line(".") })
    end, "Undo hunk under cursor")
    map("v", "<leader>hr", function()
      actions.hunk_undo(0, { vim.fn.line("."), vim.fn.line("v") })
    end, "Undo hunks in selection")
    map("n", "<leader>hR", function()
      actions.hunk_undo(0, { 1, vim.fn.line("$") })
    end, "Undo all hunks in buffer")
    map("n", "<leader>hp", function()
      actions.toggle_hunk_diff(0)
    end, "Toggle inline hunk diff")
    -- vcsigns fills its file list with `setqflist({}, "r", { nr = "$" })`:
    -- it *replaces* the newest list in the quickfix stack rather than pushing
    -- its own. During a review that newest list is quickfix-review's comment
    -- list, and opening the diff view empties it. Pushing an empty list first
    -- gives vcsigns a list of its own to overwrite and leaves the comments one
    -- level down, reachable with `:colder`.
    map("n", "<leader>hd", function()
      vim.fn.setqflist({}, " ", { title = "VCSigns diff" })
      actions.diffview(0)
    end, "Side-by-side diff view")
    map("n", "<leader>hf", function()
      actions.toggle_fold(0)
    end, "Fold outside hunks")

    -- Diff base selection: gitsigns had no equivalent. Under jj the base
    -- worth seeing shifts as `tip-add` opens each new change, so walking it
    -- interactively replaces a fixed "diff against last commit" mapping.
    --
    -- ]b / [b rather than the upstream ]r / [r: quickfix-review binds that
    -- pair to walk review comments, and matching <leader>hB keeps the two
    -- base mappings on the same letter.
    map("n", "]b", function()
      actions.target_newer_commit(0, vim.v.count1)
    end, "Diff base: newer commit")
    map("n", "[b", function()
      actions.target_older_commit(0, vim.v.count1)
    end, "Diff base: older commit")
    -- Picking beats typing here: the useful bases are commits that already
    -- exist, and a list of them with their diffs previewed answers "which
    -- one" far better than recalling a change id. Selecting the first
    -- entry clears the revset and restores the default offset base;
    -- <Esc> leaves the base where it was.
    map("n", "<leader>hB", function()
      local root = vim.fs.root(0, { ".jj" })
      if not root then
        vim.notify("No jj workspace above this buffer", vim.log.levels.ERROR)
        return
      end

      local log = vim
        .system({
          "jj",
          "-R",
          root,
          "--no-pager",
          "log",
          "-r",
          "::@",
          "--limit",
          "50",
          "--no-graph",
          "-T",
          'commit_id.short() ++ " " ++ if(description, description.first_line(), "(no description)") ++ "\n"',
        }, { text = true })
        :wait()
      if log.code ~= 0 then
        vim.notify("jj log failed: " .. vim.trim(log.stderr), vim.log.levels.ERROR)
        return
      end

      local entries = { "(default base)" }
      for line in log.stdout:gmatch("[^\n]+") do
        entries[#entries + 1] = line
      end

      require("fzf-lua").fzf_exec(entries, {
        prompt = "Diff base> ",
        preview = "jj -R " .. vim.fn.shellescape(root) .. " --no-pager show --color=always --git {1}",
        actions = {
          ["default"] = function(selected)
            local choice = selected and selected[1]
            if not choice then
              return
            end
            actions.target_revset(0, choice:match("^%x+") or "")
          end,
        },
      })
    end, "Diff base: pick commit")
  end,
}
