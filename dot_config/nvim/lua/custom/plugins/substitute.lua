return {
	"gbprod/substitute.nvim",
	config = function ()
		vim.keymap.set("n", "gs", "<cmd>lua require('substitute').operator()<cr>")
		vim.keymap.set("n", "gss", "<cmd>lua require('substitute').line()<cr>")
		vim.keymap.set("n", "gS", "<cmd>lua require('substitute').eol()<cr>")
		vim.keymap.set("x", "gs", "<cmd>lua require('substitute').visual()<cr>")
		vim.keymap.set("n", "cx", "<cmd>lua require('substitute.exchange').operator()<cr>")
		vim.keymap.set("n", "cxx", "<cmd>lua require('substitute.exchange').line()<cr>")
		vim.keymap.set("x", "X", "<cmd>lua require('substitute.exchange').visual()<cr>")
		vim.keymap.set("n", "cxc", "<cmd>lua require('substitute.exchange').cancel()<cr>")
		require("substitute").setup({
			yank_substituted_text = true,
			range = {
				prefix = "S",
			}
		})
	end
}
