return {

	"nvim-lualine/lualine.nvim",

	-- Load after UI is ready for better startup time
	event = "VeryLazy",

	dependencies = {},

	-- Use the `setup` function for configuration
	opts = {
		icons_enabled = true,
		theme = "catppuccin",
		component_separators = "|",
		section_separators = "",
		extensions = { "quickfix", "fugitive", "lazy", "mason", "nvim-dap-ui", "oil", "trouble" },
	},
}
