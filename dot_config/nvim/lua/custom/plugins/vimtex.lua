return {
  "lervag/vimtex",
  ft = { "tex", "bib" },
  -- Skim runs inverse search by starting a *new* `nvim --headless` and having
  -- it call `:VimtexInverseSearch`, which relays the position over RPC to
  -- whichever instance is editing the file. That instance opens no `.tex` of
  -- its own, so the `ft` trigger never fires there and the command does not
  -- exist -- `E492`, and the click does nothing. Naming it here gives lazy a
  -- stub that loads vimtex and re-runs it.
  cmd = { "VimtexInverseSearch" },
  -- The TOC picker below is vimtex's own `vimtex.fzf-lua` module, which
  -- `require`s fzf-lua at call time; declaring it here loads it with vimtex
  -- rather than leaving the first <space>lj to fail on a lazy plugin.
  dependencies = { "ibhagwan/fzf-lua" },
  config = function()
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_syntax_enabled = 0
    vim.g.vimtex_syntax_conceal_disable = 1

    -- Enable text objects (ic, ie, i$, etc.)
    vim.g.vimtex_text_obj_enabled = 1
    vim.g.vimtex_text_obj_variant = "auto"

    -- Enable completion for commands and bibtex
    vim.g.vimtex_complete_enabled = 1
    vim.g.vimtex_complete_close_braces = 0
    vim.g.vimtex_complete_bib = {
      simple = 1,
    }

    -- Performance settings
    vim.g.vimtex_parser_bib_backend = "lua"

    -- Error handling
    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_log_ignore = { "Underfull", "Overfull" }

    -- Disable insert mode mappings
    vim.g.vimtex_imaps_enabled = 0

    -- Avoid conflicts with existing keymaps
    vim.g.vimtex_mappings_disable = { ["n"] = { "K" } }

    -- Make <C-o>/<C-i> read as browser back/forward while editing LaTeX.
    --
    -- Walking an \input or \subfile chain builds a long jumplist, and the
    -- default keeps every entry: jumping somewhere new after <C-o> rotates the
    -- entries that were skipped over to the end of the list rather than
    -- dropping them, so position in the list stops corresponding to position in
    -- the document. "stack" discards them instead, which is what a browser does
    -- when you go back and then follow a new link.
    --
    -- `jumpoptions` is a global option with no buffer-local form, so it is
    -- swapped on entering a LaTeX buffer and put back on leaving one. The
    -- option is read when a jump is taken rather than when the jumplist is
    -- built, so this really does scope the behaviour: jumps made inside a
    -- LaTeX buffer stack, jumps made anywhere else keep whatever is configured
    -- globally. A value changed by hand while a LaTeX buffer is current is
    -- overwritten on the way out.
    local saved_jumpoptions

    local function scope_jumpoptions()
      -- Neovim makes a buffer current for the duration of an autocommand it
      -- fires for a buffer that is in no window, so `FileType` on some other
      -- plugin's scratch buffer arrives here reading that buffer's filetype
      -- and takes the restore branch. `win_gettype()` is what distinguishes
      -- that borrowed window from a real one.
      if vim.fn.win_gettype() == "autocmd" then
        return
      end
      if vim.bo.filetype == "tex" then
        if saved_jumpoptions == nil then
          saved_jumpoptions = vim.o.jumpoptions
          vim.o.jumpoptions = "stack,clean"
        end
      elseif saved_jumpoptions ~= nil then
        vim.o.jumpoptions = saved_jumpoptions
        saved_jumpoptions = nil
      end
    end

    local jump_group = vim.api.nvim_create_augroup("vimtex_jumpoptions", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
      group = jump_group,
      callback = scope_jumpoptions,
    })
    -- Restore before quitting so the value is not persisted anywhere by a
    -- session plugin mid-swap, and apply once now: this file is loaded by the
    -- LaTeX buffer that triggered it, whose BufEnter has already fired.
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = jump_group,
      callback = function()
        if saved_jumpoptions ~= nil then
          vim.o.jumpoptions = saved_jumpoptions
          saved_jumpoptions = nil
        end
      end,
    })
    scope_jumpoptions()

    -- Jump to any table-of-contents entry by fuzzy-matching its title.
    --
    -- The entries come from the same parser the `<localleader>lt` TOC window
    -- uses, so a beamer frame arrives carrying its `\frametitle`. That is what
    -- makes this the missing motion in a large deck: `]r` steps frame by frame
    -- but cannot aim at one by name.
    ---@param layers string? Entry types to keep, by first letter: `c` content
    ---  (sections and frames), `t` todo, `l` label, `i` include. Default `ci`.
    local function toc_fzf(layers)
      require("vimtex.fzf-lua").run({ layers = layers or "ci" })
    end

    vim.api.nvim_create_user_command("VimtexTocFzf", function(opts)
      toc_fzf(opts.args ~= "" and opts.args or nil)
    end, { nargs = "?", desc = "VimTeX: jump to a TOC entry (fzf)" })

    -- Describe vimtex's own keymaps to which-key.
    --
    -- vimtex creates them from Vimscript as bare `<Plug>` mappings with no
    -- `desc`, so which-key can only show the raw right-hand side -- a popup
    -- listing `<Plug>(vimtex-]r)` next to `<Plug>(vimtex-]m)` says nothing
    -- about which one finds a frame. These entries carry a description and no
    -- rhs, which registers documentation without creating a mapping, so the
    -- keys themselves stay exactly as vimtex bound them.
    --
    -- The list is deliberately partial: the maps worth recalling from a popup
    -- rather than from `:help vimtex-default-mappings`. Registration is
    -- buffer-local because none of these keys exist outside a LaTeX buffer.
    ---@param bufnr integer
    local function describe_keymaps(bufnr)
      local ok, wk = pcall(require, "which-key")
      if not ok then
        return
      end

      wk.add({
        { "<leader>l", group = "[L]aTeX", buffer = bufnr },
        { "<leader>ll", desc = "Compile (continuous)", buffer = bufnr },
        { "<leader>lS", desc = "Compile once", buffer = bufnr },
        { "<leader>lk", desc = "Stop compiling", buffer = bufnr },
        { "<leader>lv", desc = "View PDF", buffer = bufnr },
        { "<leader>le", desc = "Errors (quickfix)", buffer = bufnr },
        { "<leader>lo", desc = "Compiler output", buffer = bufnr },
        { "<leader>lq", desc = "Compiler log", buffer = bufnr },
        { "<leader>lt", desc = "Table of contents (window)", buffer = bufnr },
        { "<leader>lT", desc = "Table of contents (toggle)", buffer = bufnr },
        { "<leader>ls", desc = "Toggle main file", buffer = bufnr },
        { "<leader>li", desc = "Project info", buffer = bufnr },
        { "<leader>lc", desc = "Clean aux files", buffer = bufnr },
        { "<leader>lC", desc = "Clean aux files and PDF", buffer = bufnr },
        { "<leader>la", desc = "Context menu (under cursor)", buffer = bufnr },
        { "<leader>lx", desc = "Reload vimtex", buffer = bufnr },

        -- Navigation. `]r`/`[r` is the frame motion and the one worth
        -- remembering in a deck; `]m`/`[m` stops at every environment.
        { "]r", desc = "Next frame", buffer = bufnr, mode = { "n", "x", "o" } },
        { "[r", desc = "Prev frame", buffer = bufnr, mode = { "n", "x", "o" } },
        { "]R", desc = "Next frame end", buffer = bufnr, mode = { "n", "x", "o" } },
        { "[R", desc = "Prev frame end", buffer = bufnr, mode = { "n", "x", "o" } },
        { "]]", desc = "Next section", buffer = bufnr, mode = { "n", "x", "o" } },
        { "[[", desc = "Prev section", buffer = bufnr, mode = { "n", "x", "o" } },
        { "][", desc = "Next section end", buffer = bufnr, mode = { "n", "x", "o" } },
        { "[]", desc = "Prev section end", buffer = bufnr, mode = { "n", "x", "o" } },
        { "]m", desc = "Next environment", buffer = bufnr, mode = { "n", "x", "o" } },
        { "[m", desc = "Prev environment", buffer = bufnr, mode = { "n", "x", "o" } },
        { "]n", desc = "Next math zone", buffer = bufnr, mode = { "n", "x", "o" } },
        { "[n", desc = "Prev math zone", buffer = bufnr, mode = { "n", "x", "o" } },
        { "%", desc = "Matching delimiter/environment", buffer = bufnr, mode = { "n", "x", "o" } },

        -- Surround-style edits. These are vimtex's own cs/ds/ts trio, buffer
        -- local to a LaTeX buffer; they do not go through mini.surround.
        { "cse", desc = "Change environment", buffer = bufnr },
        { "csc", desc = "Change command", buffer = bufnr },
        { "csd", desc = "Change delimiter", buffer = bufnr },
        { "dse", desc = "Delete environment", buffer = bufnr },
        { "dsc", desc = "Delete command", buffer = bufnr },
        { "dsd", desc = "Delete delimiter", buffer = bufnr },
        { "tse", desc = "Toggle environment", buffer = bufnr },
        { "tsc", desc = "Toggle command star", buffer = bufnr },
        { "tsf", desc = "Toggle fraction", buffer = bufnr, mode = { "n", "x" } },
        { "tsd", desc = "Toggle delimiter size", buffer = bufnr, mode = { "n", "x" } },
        { "ts$", desc = "Toggle inline/display math", buffer = bufnr },

        -- Text objects, including the four rebound below.
        { "ic", desc = "Inner command", buffer = bufnr, mode = { "x", "o" } },
        { "ac", desc = "Around command", buffer = bufnr, mode = { "x", "o" } },
        { "im", desc = "Inner item", buffer = bufnr, mode = { "x", "o" } },
        { "am", desc = "Around item", buffer = bufnr, mode = { "x", "o" } },
        { "ie", desc = "Inner environment", buffer = bufnr, mode = { "x", "o" } },
        { "ae", desc = "Around environment", buffer = bufnr, mode = { "x", "o" } },
        { "id", desc = "Inner delimiter", buffer = bufnr, mode = { "x", "o" } },
        { "ad", desc = "Around delimiter", buffer = bufnr, mode = { "x", "o" } },
        { "i$", desc = "Inner math zone", buffer = bufnr, mode = { "x", "o" } },
        { "a$", desc = "Around math zone", buffer = bufnr, mode = { "x", "o" } },
      })
    end

    -- Create autocmd to prioritize vimtex text objects for tex/latex files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "tex", "latex" },
      callback = function()
        -- Prioritize vimtex's command text objects over the global ic/ac (call) in tex
        vim.keymap.set(
          "o",
          "ic",
          "<Plug>(vimtex-text-obj-command-i)",
          { buffer = true, desc = "VimTeX: Inner command" }
        )
        vim.keymap.set(
          "x",
          "ic",
          "<Plug>(vimtex-text-obj-command-i)",
          { buffer = true, desc = "VimTeX: Inner command" }
        )
        vim.keymap.set(
          "o",
          "ac",
          "<Plug>(vimtex-text-obj-command-a)",
          { buffer = true, desc = "VimTeX: Around command" }
        )
        vim.keymap.set(
          "x",
          "ac",
          "<Plug>(vimtex-text-obj-command-a)",
          { buffer = true, desc = "VimTeX: Around command" }
        )

        -- Prioritize vimtex's item text objects over various-textobjs' chainMember
        vim.keymap.set("o", "im", "<Plug>(vimtex-text-obj-item-i)", { buffer = true, desc = "VimTeX: Inner item" })
        vim.keymap.set("x", "im", "<Plug>(vimtex-text-obj-item-i)", { buffer = true, desc = "VimTeX: Inner item" })
        vim.keymap.set("o", "am", "<Plug>(vimtex-text-obj-item-a)", { buffer = true, desc = "VimTeX: Around item" })
        vim.keymap.set("x", "am", "<Plug>(vimtex-text-obj-item-a)", { buffer = true, desc = "VimTeX: Around item" })

        vim.keymap.set("n", "<leader>lj", toc_fzf, { buffer = true, desc = "VimTeX: TOC (fzf)" })

        describe_keymaps(vim.api.nvim_get_current_buf())
      end,
    })
  end,
}
