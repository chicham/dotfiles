return {
  'https://github.com/haya14busa/vim-asterisk',
 config = function ()
    vim.cmd([[ let g:asterisk#keeppos = 1 ]])
    vim.keymap.set("n", "*", "<Plug>(asterisk-z*)<Plug>(is-nohl-1)")
    vim.keymap.set("n", "n", ":norm! nzzzv<Plug>Pulse<CR>")
    vim.keymap.set("n", "n", ":norm! Nzzzv<Plug>Pulse<CR>")
 end
}
