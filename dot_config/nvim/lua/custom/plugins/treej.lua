return {
  'https://github.com/Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('treesj').setup({
      use_default_keymaps = false,
    })
    vim.keymap.set('n', 'gS', require('treesj').toggle)
  end,
}
