return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "LspAttach",
	config = function()
		require("tiny-inline-diagnostic").setup({
			preset = "minimal",
			-- Only show warnings and errors, hide hints and info
			severity = {
				vim.diagnostic.severity.ERROR,
				vim.diagnostic.severity.WARN,
			},
		})

		-- Configure Neovim's diagnostic display
		vim.diagnostic.config({
			virtual_text = false, -- Disable built-in virtual text since we use tiny-inline-diagnostic
			signs = {
				-- Only show signs for warnings and above
				severity = { min = vim.diagnostic.severity.WARN }
			},
			underline = {
				-- Only show underlines for errors
				severity = { min = vim.diagnostic.severity.ERROR }
			},
			float = {
				-- Only show floating windows for warnings and above
				severity = { min = vim.diagnostic.severity.WARN }
			},
			severity_sort = true,
		})
	end,
}
