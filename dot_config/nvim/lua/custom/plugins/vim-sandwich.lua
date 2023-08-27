return {
	"machakann/vim-sandwich",
	config = function ()
		vim.keymap.set('n', 's', '<Nop>')
		vim.keymap.set('x', 's', '<Nop>')
		-- vim.keymap.set('x', 'is', '<Plug>(textobj-sandwich-query-i)')
		-- vim.keymap.set('x', 'as', '<Plug>(textobj-sandwich-query-a)')
		-- vim.keymap.set('o', 'is', '<Plug>(textobj-sandwich-query-i)')
		-- vim.keymap.set('o', 'as', '<Plug>(textobj-sandwich-query-a)')
		vim.keymap.set('x', 'ib', '<Plug>(textobj-sandwich-auto-i)')
		vim.keymap.set('x', 'ab', '<Plug>(textobj-sandwich-auto-a)')
		vim.keymap.set('o', 'ib', '<Plug>(textobj-sandwich-auto-i)')
		vim.keymap.set('o', 'ab', '<Plug>(textobj-sandwich-auto-a)')
		vim.keymap.set('x', 'im', '<Plug>(textobj-sandwich-literal-query-i)')
		vim.keymap.set('x', 'am', '<Plug>(textobj-sandwich-literal-query-a)')
		vim.keymap.set('o', 'im', '<Plug>(textobj-sandwich-literal-query-i)')
		vim.keymap.set('o', 'am', '<Plug>(textobj-sandwich-literal-query-a)')
		vim.cmd([[ runtime! macros/sandwich/keymap/surround.vim ]])
	end
}
