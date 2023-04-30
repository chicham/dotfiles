return {
	"mbbill/undotree",
	conffig = function ()
		vim.keymap.set('n', 'U', vim.cmd.UndotreeToggle)
	end
}
