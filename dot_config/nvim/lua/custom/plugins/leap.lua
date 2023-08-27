return {
	'ggandor/leap.nvim',
	config = function()
		require('leap').setup {
			safe_labels = { 't', 's', 'r', 'n', 'm', 'e', 'i', 'u', 'a' },
			labels = { 't', 's', 'r', 'n', 'm', 'e', 'i', 'u', 'a', 'v', 'd', 'l', 'j', 'z', 'b', 'é', 'p', 'o' },
		}
		vim.keymap.set({ 'n', 'x', 'o' }, ',', '<Plug>(leap-forward-to)')
		vim.keymap.set({ 'n', 'x', 'o' }, ';', '<Plug>(leap-backward-to)')
		vim.keymap.set({ 'n', 'x', 'o' }, 'g,', '<Plug>(leap-from-window)')
	end,
}
