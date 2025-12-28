return {
  'lervag/vimtex',
  ft = { 'tex', 'bib' },
  dependencies = { 'machakann/vim-sandwich' },
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

    -- Create autocmd to prioritize vimtex text objects for tex/latex files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {"tex", "latex"},
      callback = function()
        -- Prioritize vimtex's command text objects over Treesitter's class text objects
        vim.keymap.set('o', 'ic', '<Plug>(vimtex-text-obj-command-i)', { buffer = true, desc = "VimTeX: Inner command" })
        vim.keymap.set('x', 'ic', '<Plug>(vimtex-text-obj-command-i)', { buffer = true, desc = "VimTeX: Inner command" })
        vim.keymap.set('o', 'ac', '<Plug>(vimtex-text-obj-command-a)', { buffer = true, desc = "VimTeX: Around command" })
        vim.keymap.set('x', 'ac', '<Plug>(vimtex-text-obj-command-a)', { buffer = true, desc = "VimTeX: Around command" })

        -- Prioritize vimtex's item text objects over various-textobjs' chainMember
        vim.keymap.set('o', 'im', '<Plug>(vimtex-text-obj-item-i)', { buffer = true, desc = "VimTeX: Inner item" })
        vim.keymap.set('x', 'im', '<Plug>(vimtex-text-obj-item-i)', { buffer = true, desc = "VimTeX: Inner item" })
        vim.keymap.set('o', 'am', '<Plug>(vimtex-text-obj-item-a)', { buffer = true, desc = "VimTeX: Around item" })
        vim.keymap.set('x', 'am', '<Plug>(vimtex-text-obj-item-a)', { buffer = true, desc = "VimTeX: Around item" })

        -- Prevent sandwich surround operations from using vimtex text objects to avoid freezing
        vim.keymap.set('n', 'ysae', '<Nop>', { buffer = true, desc = "Disabled: use vimtex commands instead" })
        vim.keymap.set('n', 'ysie', '<Nop>', { buffer = true, desc = "Disabled: use vimtex commands instead" })
        vim.keymap.set('n', 'ysac', '<Nop>', { buffer = true, desc = "Disabled: use vimtex commands instead" })
        vim.keymap.set('n', 'ysic', '<Nop>', { buffer = true, desc = "Disabled: use vimtex commands instead" })
        vim.keymap.set('n', 'ysam', '<Nop>', { buffer = true, desc = "Disabled: use vimtex commands instead" })
        vim.keymap.set('n', 'ysim', '<Nop>', { buffer = true, desc = "Disabled: use vimtex commands instead" })
      end,
    })
  end,
}
