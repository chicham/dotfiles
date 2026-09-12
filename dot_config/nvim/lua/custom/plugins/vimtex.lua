return {
  'lervag/vimtex',
  ft = { 'tex', 'bib' },
  config = function()
    vim.g.vimtex_view_method = 'skim'
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_syntax_enabled = 0
    vim.g.vimtex_syntax_conceal_disable = 1

    -- Enable text objects (ic, ie, i$, etc.)
    vim.g.vimtex_text_obj_enabled = 1
    vim.g.vimtex_text_obj_variant = 'auto'

    -- Enable completion for commands and bibtex
    vim.g.vimtex_complete_enabled = 1
    vim.g.vimtex_complete_close_braces = 0
    vim.g.vimtex_complete_bib = {
      simple = 1,
    }

    -- Performance settings
    vim.g.vimtex_parser_bib_backend = 'lua'

    -- Error handling
    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_log_ignore = {'Underfull', 'Overfull'}

    -- Disable insert mode mappings
    vim.g.vimtex_imaps_enabled = 0

    -- Avoid conflicts with existing keymaps
    vim.g.vimtex_mappings_disable = { ['n'] = {'K'} }

    -- Jump to any table-of-contents entry by fuzzy-matching its title.
    --
    -- vimtex ships its own fzf bridge, but it calls `fzf#run()` from
    -- junegunn/fzf.vim, which is not installed; fzf-lua is the picker here.
    -- The entries come from the same parser the `<localleader>lt` TOC window
    -- uses, so a beamer frame arrives carrying its `\frametitle` -- which is
    -- what makes this the missing motion in a large deck, where `]r` steps
    -- frame by frame but cannot aim at one by name.
    ---@param filter string? Entry types to keep, by first letter: `c` content
    ---  (sections and frames), `t` todo, `l` label, `i` include. Default `ci`.
    local function toc_fzf(filter)
      filter = filter or 'ci'

      -- Entries are only produced for a file vimtex has a project state for.
      local ok, entries = pcall(vim.fn['vimtex#parser#toc'])
      if not ok or vim.tbl_isempty(entries or {}) then
        vim.notify('vimtex: no table of contents for this buffer', vim.log.levels.WARN)
        return
      end

      -- fzf-lua matches on the whole displayed line, so the file:line prefix
      -- has to stay out of it; the index into `entries` is carried instead and
      -- stripped back off in the action.
      local lines = {}
      for i, e in ipairs(entries) do
        if filter:find(e.type:sub(1, 1), 1, true) then
          local indent = string.rep('  ', math.max(0, tonumber(e.level) or 0))
          lines[#lines + 1] = string.format('%d\t%s%s', i, indent, e.title)
        end
      end

      require('fzf-lua').fzf_exec(lines, {
        prompt = 'TOC> ',
        fzf_opts = { ['--with-nth'] = '2..', ['--delimiter'] = '\\t' },
        actions = {
          ['default'] = function(selected)
            if not selected or not selected[1] then return end
            local e = entries[tonumber(selected[1]:match('^(%d+)'))]
            if not e then return end
            vim.cmd.edit(vim.fn.fnameescape(e.file))
            vim.api.nvim_win_set_cursor(0, { tonumber(e.line) or 1, 0 })
            vim.cmd('normal! zz')
          end,
        },
      })
    end

    vim.api.nvim_create_user_command('VimtexTocFzf', function(opts)
      toc_fzf(opts.args ~= '' and opts.args or nil)
    end, { nargs = '?', desc = 'VimTeX: jump to a TOC entry (fzf)' })

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
      local ok, wk = pcall(require, 'which-key')
      if not ok then return end

      wk.add({
        { '<leader>l', group = '[L]aTeX', buffer = bufnr },
        { '<leader>ll', desc = 'Compile (continuous)', buffer = bufnr },
        { '<leader>lS', desc = 'Compile once', buffer = bufnr },
        { '<leader>lk', desc = 'Stop compiling', buffer = bufnr },
        { '<leader>lv', desc = 'View PDF', buffer = bufnr },
        { '<leader>le', desc = 'Errors (quickfix)', buffer = bufnr },
        { '<leader>lo', desc = 'Compiler output', buffer = bufnr },
        { '<leader>lq', desc = 'Compiler log', buffer = bufnr },
        { '<leader>lt', desc = 'Table of contents (window)', buffer = bufnr },
        { '<leader>lT', desc = 'Table of contents (toggle)', buffer = bufnr },
        { '<leader>ls', desc = 'Toggle main file', buffer = bufnr },
        { '<leader>li', desc = 'Project info', buffer = bufnr },
        { '<leader>lc', desc = 'Clean aux files', buffer = bufnr },
        { '<leader>lC', desc = 'Clean aux files and PDF', buffer = bufnr },
        { '<leader>la', desc = 'Context menu (under cursor)', buffer = bufnr },
        { '<leader>lx', desc = 'Reload vimtex', buffer = bufnr },

        -- Navigation. `]r`/`[r` is the frame motion and the one worth
        -- remembering in a deck; `]m`/`[m` stops at every environment.
        { ']r', desc = 'Next frame', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { '[r', desc = 'Prev frame', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { ']R', desc = 'Next frame end', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { '[R', desc = 'Prev frame end', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { ']]', desc = 'Next section', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { '[[', desc = 'Prev section', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { '][', desc = 'Next section end', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { '[]', desc = 'Prev section end', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { ']m', desc = 'Next environment', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { '[m', desc = 'Prev environment', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { ']n', desc = 'Next math zone', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { '[n', desc = 'Prev math zone', buffer = bufnr, mode = { 'n', 'x', 'o' } },
        { '%', desc = 'Matching delimiter/environment', buffer = bufnr, mode = { 'n', 'x', 'o' } },

        -- Surround-style edits, sharing the `s` prefix already grouped globally.
        { 'cse', desc = 'Change environment', buffer = bufnr },
        { 'csc', desc = 'Change command', buffer = bufnr },
        { 'csd', desc = 'Change delimiter', buffer = bufnr },
        { 'dse', desc = 'Delete environment', buffer = bufnr },
        { 'dsc', desc = 'Delete command', buffer = bufnr },
        { 'dsd', desc = 'Delete delimiter', buffer = bufnr },
        { 'tse', desc = 'Toggle environment', buffer = bufnr },
        { 'tsc', desc = 'Toggle command star', buffer = bufnr },
        { 'tsf', desc = 'Toggle fraction', buffer = bufnr, mode = { 'n', 'x' } },
        { 'tsd', desc = 'Toggle delimiter size', buffer = bufnr, mode = { 'n', 'x' } },
        { 'ts$', desc = 'Toggle inline/display math', buffer = bufnr },

        -- Text objects, including the four rebound below.
        { 'ic', desc = 'Inner command', buffer = bufnr, mode = { 'x', 'o' } },
        { 'ac', desc = 'Around command', buffer = bufnr, mode = { 'x', 'o' } },
        { 'im', desc = 'Inner item', buffer = bufnr, mode = { 'x', 'o' } },
        { 'am', desc = 'Around item', buffer = bufnr, mode = { 'x', 'o' } },
        { 'ie', desc = 'Inner environment', buffer = bufnr, mode = { 'x', 'o' } },
        { 'ae', desc = 'Around environment', buffer = bufnr, mode = { 'x', 'o' } },
        { 'id', desc = 'Inner delimiter', buffer = bufnr, mode = { 'x', 'o' } },
        { 'ad', desc = 'Around delimiter', buffer = bufnr, mode = { 'x', 'o' } },
        { 'i$', desc = 'Inner math zone', buffer = bufnr, mode = { 'x', 'o' } },
        { 'a$', desc = 'Around math zone', buffer = bufnr, mode = { 'x', 'o' } },
      })
    end

    -- Create autocmd to prioritize vimtex text objects for tex/latex files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {"tex", "latex"},
      callback = function()
        -- Prioritize vimtex's command text objects over the global ic/ac (call) in tex
        vim.keymap.set('o', 'ic', '<Plug>(vimtex-text-obj-command-i)', { buffer = true, desc = "VimTeX: Inner command" })
        vim.keymap.set('x', 'ic', '<Plug>(vimtex-text-obj-command-i)', { buffer = true, desc = "VimTeX: Inner command" })
        vim.keymap.set('o', 'ac', '<Plug>(vimtex-text-obj-command-a)', { buffer = true, desc = "VimTeX: Around command" })
        vim.keymap.set('x', 'ac', '<Plug>(vimtex-text-obj-command-a)', { buffer = true, desc = "VimTeX: Around command" })

        -- Prioritize vimtex's item text objects over various-textobjs' chainMember
        vim.keymap.set('o', 'im', '<Plug>(vimtex-text-obj-item-i)', { buffer = true, desc = "VimTeX: Inner item" })
        vim.keymap.set('x', 'im', '<Plug>(vimtex-text-obj-item-i)', { buffer = true, desc = "VimTeX: Inner item" })
        vim.keymap.set('o', 'am', '<Plug>(vimtex-text-obj-item-a)', { buffer = true, desc = "VimTeX: Around item" })
        vim.keymap.set('x', 'am', '<Plug>(vimtex-text-obj-item-a)', { buffer = true, desc = "VimTeX: Around item" })

        vim.keymap.set('n', '<leader>lj', toc_fzf, { buffer = true, desc = "VimTeX: TOC (fzf)" })

        describe_keymaps(vim.api.nvim_get_current_buf())
      end,
    })
  end,
}
