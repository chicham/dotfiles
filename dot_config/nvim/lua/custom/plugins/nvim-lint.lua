return {
	'https://github.com/mfussenegger/nvim-lint',
	config = function ()
		require("lint").linters_by_ft = {
			python = {"ruff", },
			lua = {"luacheck", },
		}
	end
}
