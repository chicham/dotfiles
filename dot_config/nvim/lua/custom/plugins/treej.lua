return {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('treesj').setup({
			use_default_keymaps = true,
		})
		vim.keymap.set('n', 'gS', require('treesj').toggle)
		-- vim.keymap.set('n', 'gS', require('treesj').split)
		-- vim.keymap.set('n', 'gJ', require('treesj').join)
  end,
}
