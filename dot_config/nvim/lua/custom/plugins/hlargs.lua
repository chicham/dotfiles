return {
	"m-demare/hlargs.nvim",

	-- Lazy loading for potential performance gain
	lazy = true, -- Load only when needed

	-- Use the `setup` function directly for configuration
	setup = {
		excluded_argnames = {
			declarations = {
				python = { "self", "cls" },
			},
			usages = {
				python = { "self", "cls" },
				lua = { "self" },
			},
		},

		-- for potential performance improvement (if applicable)
		hl_mode = " BufRead", -- Uncomment if you want to try this
	},
}
