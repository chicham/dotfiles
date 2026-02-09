-- code-preview.nvim -- diff preview of AI-agent (Claude Code, etc.) file edits
-- before accepting/rejecting them. Pairs with claudecode.nvim.
--
-- Loaded on VeryLazy rather than on its :CodePreview* commands because the
-- preview is triggered by agent hooks calling into the running instance, so the
-- plugin must already be live to receive them -- VeryLazy keeps it off the
-- startup critical path while still being ready by the time you start editing.
return {
	"Cannon07/code-preview.nvim",
	event = "VeryLazy",
	opts = {
		-- We use oil.nvim, not neo-tree -- disable the neo-tree integration so
		-- the plugin doesn't expect a tree plugin we don't have installed.
		neo_tree = { enabled = false },
	},
}
