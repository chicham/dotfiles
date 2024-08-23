return {
	"https://github.com/akinsho/git-conflict.nvim",
	opts = {
		default_mappings = false, -- Disable default mappings to avoid conflicts
	},
	keys = {
		-- Resolve Conflicts
		{ "<leader>co", "<Plug>(git-conflict-ours)", desc = "Use ours version to resolve conflict" },
		{ "<leader>ct", "<Plug>(git-conflict-theirs)", desc = "Use theirs version to resolve conflict" },
		{ "<leader>cb", "<Plug>(git-conflict-both)", desc = "Use both versions to resolve conflict" },
		{ "<leader>c0", "<Plug>(git-conflict-none)", desc = "Discard both versions to resolve conflict" },

		-- Navigate Conflicts (consider potential overlap with gitsigns)
		{ "[x", "<Plug>(git-conflict-prev-conflict)", desc = "Go to previous conflict" },
		{ "]x", "<Plug>(git-conflict-next-conflict)", desc = "Go to next conflict" },
	},
}
