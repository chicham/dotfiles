return {
	"julienvincent/hunk.nvim",
	dependencies = { "MunifTanjim/nui.nvim" },
	-- Only ever needed when jj/git launches nvim as the diff-editor, which runs
	-- `:DiffEditor $left $right $output` (see jj config.toml [ui] diff-editor).
	-- Loading on that command means zero cost in normal editing sessions and
	-- nui.nvim is never pulled in unless you're actually resolving a diff.
	cmd = { "DiffEditor" },
	config = function()
		require("hunk").setup()
	end,
}
