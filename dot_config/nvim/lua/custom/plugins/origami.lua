return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	dependencies = {
		"lewis6991/gitsigns.nvim"
	},
	opts = {}, -- needed even when using default config

	-- recommended: disable vim's auto-folding
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
	end,
}
