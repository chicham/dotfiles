-- fzf-lua.lua
-- Fast and powerful fuzzy finder using FZF
return {
  "ibhagwan/fzf-lua",
  -- Deferred off the startup critical path. VeryLazy fires right after the
  -- first screen is drawn, at which point register_ui_select() and all the
  -- keymaps below are installed -- so vim.ui.select and the <leader>f/g maps
  -- are ready before any interactive use. :FzfLua also force-loads it.
  event = "VeryLazy",
  cmd = "FzfLua",
  dependencies = {
    "nvim-mini/mini.icons", -- Optional for file icons
  },
  config = function()
    local fzf = require("fzf-lua")

    -- Register fzf-lua as the UI select handler
    fzf.register_ui_select()

    -- Setup fzf-lua with fullscreen layout
    fzf.setup({
      -- Base configuration using the 'ivy' preset for bottom layout
      "ivy",
      winopts = {
        fullscreen = true, -- Start fullscreen
        preview = {
          layout = "vertical", -- Stack preview above suggestions
          vertical = "up:75%", -- Preview takes 75% of the window height
        },
      },
      keymap = {
        builtin = {
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
      },
      fzf_opts = {
        -- Additional FZF options for bottom layout
        ["--layout"] = "reverse-list",
        ["--info"] = "inline",
      },
    })

    -- g-mappings: Replace nvim goto commands with fzf (lowercase=document, uppercase=workspace)
    vim.keymap.set("n", "gd", fzf.lsp_definitions, { desc = "Go to definitions" })
    vim.keymap.set("n", "gr", fzf.lsp_references, { desc = "Go to references" })
    vim.keymap.set("n", "gD", fzf.lsp_declarations, { desc = "Go to declarations" })
    vim.keymap.set("n", "gi", fzf.lsp_implementations, { desc = "Go to implementations" })
    vim.keymap.set("n", "gy", fzf.lsp_typedefs, { desc = "Go to type definitions" })
    vim.keymap.set("n", "gb", fzf.buffers, { desc = "Go to buffer" })
    vim.keymap.set("n", "gs", fzf.lsp_document_symbols, { desc = "Go to symbol (document)" })
    vim.keymap.set("n", "gS", fzf.lsp_live_workspace_symbols, { desc = "Go to symbol (workspace)" })

    -- <leader>f: All fzf operations
    -- Files & navigation
    vim.keymap.set("n", "<leader>ff", fzf.lsp_document_symbols, { desc = "Find symbols (document)" })
    vim.keymap.set("n", "<leader>fe", function()
      -- Use git_files with fallback to regular files if not in git repo
      fzf.git_files({
        cwd = vim.fn.getcwd(),
        cmd = "git ls-files --exclude-standard --cached --others",
        fail = function()
          fzf.files()
        end,
      })
    end, { desc = "Edit/open files (git with fallback)" })
    vim.keymap.set("n", "<leader>fm", fzf.marks, { desc = "Find marks" })
    vim.keymap.set("n", "<leader>fo", function()
      fzf.files({
        cwd = vim.fn.expand("~/.orgfiles"),
        prompt = "OrgFiles> ",
      })
    end, { desc = "Find any org files" })

    vim.keymap.set("n", "<leader>fh", function()
      fzf.grep({
        search = "^\\*+\\s",
        cwd = vim.fn.expand("~/.orgfiles"),
        prompt = "OrgHeadlines> ",
        no_esc = true,
        rg_opts = "--column --line-number --no-heading --color=always --smart-case",
      })
    end, { desc = "Find Org headlines" })

    -- Search operations
    vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Find by grep (live)" })
    vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "Find word under cursor" })
    vim.keymap.set("n", "<leader>fv", fzf.grep_visual, { desc = "Find visual selection" })
    vim.keymap.set("n", "<leader>f/", fzf.grep_curbuf, { desc = "Find in current buffer" })
    vim.keymap.set("n", "<leader>ft", function()
      -- Get comment string from vim.bo.commentstring (e.g., "-- %s" for Lua, "# %s" for Python)
      local commentstring = vim.bo.commentstring
      if commentstring == "" then
        -- Fallback for filetypes without commentstring
        fzf.grep_curbuf({
          search = "(TODO|XXX|FIXME|BUG)(:|\\(.*\\):|\\s|$)",
          no_esc = true,
          rg_opts = "--no-heading --color=always --smart-case",
        })
        return
      end

      -- Extract comment symbol (everything before %s)
      local comment_symbol = commentstring:match("(.-)%%s") or commentstring
      comment_symbol = vim.trim(comment_symbol)

      -- Escape special regex characters for ripgrep
      comment_symbol = comment_symbol:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?\\])", "\\%1")

      -- Build pattern: comment + space + TODO variants (TODO, TODO:, TODO(scope):)
      local pattern = "^\\s*" .. comment_symbol .. "\\s*(TODO|XXX|FIXME|BUG)(:|\\(.*\\):|\\s|$)"

      fzf.grep_curbuf({
        search = pattern,
        no_esc = true,
        rg_opts = "--no-heading --color=always --smart-case",
      })
    end, { desc = "Find TODOs/FIXMEs in comments (current buffer)" })
    vim.keymap.set("n", "<leader>fT", function()
      -- Pattern to match TODO variants: TODO, TODO:, TODO(scope):
      local pattern = "(TODO|XXX|FIXME|BUG)(:|\\(.*\\):|\\s|$)"

      fzf.grep({
        search = pattern,
        no_esc = true,
        rg_opts = "--no-heading --color=always --smart-case",
      })
    end, { desc = "Find TODOs/FIXMEs (workspace)" })

    -- LSP & diagnostics (lowercase=document, uppercase=workspace)
    vim.keymap.set("n", "<leader>fa", fzf.lsp_code_actions, { desc = "Find code actions" })
    vim.keymap.set("n", "<leader>fd", fzf.diagnostics_document, { desc = "Find diagnostics (document)" })
    vim.keymap.set("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Find diagnostics (workspace)" })

    -- code-preview: jump to a pending diff tab. Each agent-edited file opens
    -- its own diff tab; `gt` is remapped to LSP typedefs above, so this picker
    -- is the way to switch between them. Lists pending files (with change
    -- status) and switches to the selected file's tab on <CR>.
    vim.keymap.set("n", "<leader>fp", function()
      local ok, diff = pcall(require, "code-preview.diff")
      if not ok then
        vim.notify("code-preview not loaded", vim.log.levels.WARN)
        return
      end
      local active = diff._active_diffs()
      local has_changes, changes = pcall(require, "code-preview.changes")
      local status_of = has_changes and changes.get_all() or {}

      local entries, lookup = {}, {}
      for path, entry in pairs(active) do
        if entry.tab and vim.api.nvim_tabpage_is_valid(entry.tab) then
          local status = status_of[path] and (status_of[path] .. "  ") or ""
          local display = status .. vim.fn.fnamemodify(path, ":~:.")
          entries[#entries + 1] = display
          lookup[display] = entry.tab
        end
      end

      if #entries == 0 then
        vim.notify("No pending code-preview diffs", vim.log.levels.INFO)
        return
      end

      fzf.fzf_exec(entries, {
        prompt = "DiffTabs> ",
        actions = {
          ["default"] = function(selected)
            local tab = selected and selected[1] and lookup[selected[1]]
            if tab and vim.api.nvim_tabpage_is_valid(tab) then
              vim.api.nvim_set_current_tabpage(tab)
            end
          end,
        },
      })
    end, { desc = "Find code-preview diff tabs" })

    -- Utility
    vim.keymap.set("n", "<leader>fC", fzf.command_history, { desc = "Find command history" })
    vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "Find keymaps" })
    vim.keymap.set("n", "<leader>fr", fzf.oldfiles, { desc = "Find recent files" })
    vim.keymap.set("n", "<leader>fR", fzf.resume, { desc = "Resume last search" })

    -- Replace standard spell suggest
    vim.keymap.set("n", "z=", fzf.spell_suggest, { desc = "Spell suggest" })

    -- Command palette
    vim.keymap.set("n", "<leader>:", fzf.commands, { desc = "Command Palette" })
  end,
}
