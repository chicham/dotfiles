return {
	"https://github.com/chentoast/marks.nvim",
	config = function ()
		require("marks").setup {
			mappings = {
				set_next = "m.",
				preview = "m,",
			}
		}
	end
}
