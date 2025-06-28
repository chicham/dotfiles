return {
  'editorconfig/editorconfig-vim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    vim.g.EditorConfig_exclude_patterns = { 'fugitive://.*', 'scp://.*' }
  end,
}
