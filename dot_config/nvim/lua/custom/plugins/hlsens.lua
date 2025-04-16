return {
  'https://github.com/kevinhwang91/nvim-hlslens',
  dependencies = { 'haya14busa/vim-asterisk' },
  opts = {
    calm_down = true,
    nearest_only = true,
  },

  keys = {
    { '*', '<Plug>(asterisk-z*)<Cmd>lua require("hlslens").start()<CR>', mode = { 'n', 'x' } },
    { '#', '<Plug>(asterisk-z#)<Cmd>lua require("hlslens").start()<CR>', mode = { 'n', 'x' } },
    { 'g*', '<Plug>(asterisk-gz*)<Cmd>lua require("hlslens").start()<CR>', mode = { 'n', 'x' } },
    { 'g#', '<Plug>(asterisk-gz#)<Cmd>lua require("hlslens").start()<CR>', mode = { 'n', 'x' } },
  },
}
