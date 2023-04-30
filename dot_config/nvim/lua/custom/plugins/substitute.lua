return {
	"gbprod/substitute.nvim",
	config = function ()
		vim.keymap.set("n", "gx", require('substitute').operator, { noremap = true })
		vim.keymap.set("n", "gxx", require('substitute').line, { noremap = true })
		vim.keymap.set("n", "gX", require('substitute').eol, { noremap = true })
		vim.keymap.set("x", "gx", require('substitute').visual, { noremap = true })
		vim.keymap.set("n", "cx", require('substitute.exchange').operator, { noremap = true })
		vim.keymap.set("n", "cxx", require('substitute.exchange').line, { noremap = true })
		vim.keymap.set("x", "X", require('substitute.exchange').visual, { noremap = true })
		require("substitute").setup({
			yank_substituted_text = true,
			range = {
				prefix = "S",
			}
		})
	end
}
