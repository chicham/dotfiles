return {
  'alker0/chezmoi.vim',
  event = { 'BufReadPre', 'BufNewFile' },
  init = function()
    -- This option is required.
    vim.g['chezmoi#use_tmp_buffer'] = true
    -- add other options here if needed.
  end,
}
