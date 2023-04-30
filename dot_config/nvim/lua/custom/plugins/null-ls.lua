return {
	"jose-elias-alvarez/null-ls.nvim",
	config = function ()
		require("null-ls").setup({
		require("null-ls").builtins.code_actions.gitsigns,
		require("null-ls").builtins.code_actions.eslint_d,
		require("null-ls").builtins.formatting.stylua,
		require("null-ls").builtins.formatting.black,
		require("null-ls").builtins.formatting.ruff,
		require("null-ls").builtins.formatting.latexindent,
		require("null-ls").builtins.formatting.prettier.with({
			filetypes = { "html", "json", "yaml", "markdown" },
			extra_args = { "--print-width", "4" },
		}),
		require("null-ls").builtins.diagnostics.eslint,
		require("null-ls").builtins.diagnostics.chktex,
		require("null-ls").builtins.diagnostics.fish,
		require("null-ls").builtins.diagnostics.gitlint,
		require("null-ls").builtins.diagnostics.luacheck,
		require("null-ls").builtins.diagnostics.trail_space,
		require("null-ls").builtins.diagnostics.yamllint,
		require("null-ls").builtins.diagnostics.ruff,
	})
	end
}
