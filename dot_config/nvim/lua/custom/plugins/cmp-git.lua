return {
	"petertriho/cmp-git",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function ()
		require("cmp_git").setup()
	end
}
