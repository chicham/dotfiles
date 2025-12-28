return {
  'https://github.com/Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  opts = {
    use_default_keymaps = false,
  },
  keys = {
    {
      'gJ',
      function()
        require('treesj').toggle()
      end,
      desc = 'Split/Join Block',
    },
  },
}
