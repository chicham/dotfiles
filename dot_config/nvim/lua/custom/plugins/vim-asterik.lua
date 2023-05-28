return {
  'https://github.com/haya14busa/vim-asterisk',
 config = function ()
    vim.cmd([[ let g:asterisk#keeppos = 1 ]])
    vim.keymap.set("n", "*", "<Plug>(asterisk-z*)zz<Plug>(is-nohl-1)")
    vim.keymap.set("n", "#", "<Plug>(asterisk-z#)zz<Plug>(is-nohl-1)")
    vim.keymap.set("n", "n", "<Plug>(is-n)zz", {silent = true})
    vim.keymap.set("n", "N", "<Plug>(is-N)zz", {silent = true})
 end
}
