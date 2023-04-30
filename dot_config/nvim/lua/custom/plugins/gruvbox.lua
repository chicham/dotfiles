return {
	'ellisonleao/gruvbox.nvim',
	config = function ()
		require("gruvbox").setup({
			contrast = "",
			italic = {
				strings = false,
				comments = true,
				operators = false,
				folds = false,
			},
		})
		vim.o.background = "dark" -- or "light" for light mode
		vim.cmd([[colorscheme gruvbox]])
	end
}
