return {
  'https://github.com/lervag/vimtex',
  lazy = false,
  dependencies = { 'micangl/cmp-vimtex' },
  config = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_view_method = 'skim'
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_syntax_enabled = 0
    vim.g.vimtex_syntax_conceal_disable = 1
  end,
}
