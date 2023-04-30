return {
	"ray-x/lsp_signature.nvim",
	config = function ()
		require("lsp_signature").setup({
			float_window = false,
			bind = true,
			hint_enable = true,
			hint_prefix = "",
			hint_scheme = "Comment",
			-- handler_opts = { border = "single" },
			-- max_width = 80,
})
	end
}
