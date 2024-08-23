return {
	"windwp/nvim-autopairs",
	lazy = true,
	dependencies = { "hrsh7th/nvim-cmp", "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("nvim-autopairs").setup({
			disable_in_macro = true,
			enable_check_bracket_line = true,
			ignored_next_char = "[%w%.]",
			check_ts = true,
			ts_config = {
				lua = { "string" },
				javascript = { "template_string" },
				java = false,
			},
		})

		-- Integrate with nvim-cmp
		require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
	end,
}
