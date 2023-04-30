return {
	"ggandor/leap.nvim",
	config = function ()
		require('leap').setup {
			labels = { 'e', 'i', 'u', 't', 's', 'r',  'a', 'm', 'k', 'q', 'x', 'g' },
		}
		vim.keymap.set({ 'n', 'x', 'o' }, ',', '<Plug>(leap-forward-to)')
		vim.keymap.set({ 'n', 'x', 'o' }, ';', '<Plug>(leap-backward-to)')
	end
}
