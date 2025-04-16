return {

	"nvim-lualine/lualine.nvim",

	-- Use 'lazy = true' to load the plugin only when needed
	-- lazy = true,

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
