return {
	"https://github.com/chentoast/marks.nvim",
	config = function ()
		require("marks").setup {
			mappings = {
				set_next = "m.",
				delete_line = "m:",
				preview = "gm",
				delete_buf = "m<space>",
				toggle = "m,"
			}
		}
	end
}
