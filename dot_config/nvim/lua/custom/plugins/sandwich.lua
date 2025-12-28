return {
  'machakann/vim-sandwich',
  lazy = false,
  keys = {
    { 'sa', desc = 'Add Surround', mode = { 'n', 'x' } },
    { 'sd', desc = 'Delete Surround' },
    { 'sr', desc = 'Replace Surround' },
  },
  config = function()
    -- Load surround keymapping (provides ys, ds, cs)
    vim.cmd [[ runtime macros/sandwich/keymap/surround.vim ]]

    -- Enable textobj-sandwich functionality
    vim.cmd [[ runtime autoload/textobj/sandwich.vim ]]

    -- Define 'ib' and 'ab' for 'auto' detection (any bracket/quote)
    vim.keymap.set('o', 'ib', '<Plug>(textobj-sandwich-auto-i)', { desc = 'Sandwich: Inner auto-detected block' })
    vim.keymap.set('x', 'ib', '<Plug>(textobj-sandwich-auto-i)', { desc = 'Sandwich: Inner auto-detected block' })
    vim.keymap.set('o', 'ab', '<Plug>(textobj-sandwich-auto-a)', { desc = 'Sandwich: Around auto-detected block' })
    vim.keymap.set('x', 'ab', '<Plug>(textobj-sandwich-auto-a)', { desc = 'Sandwich: Around auto-detected block' })

    -- Define 'is' and 'as' for query-based detection
    vim.keymap.set('o', 'is', '<Plug>(textobj-sandwich-query-i)', { desc = 'Sandwich: Inner query block' })
    vim.keymap.set('x', 'is', '<Plug>(textobj-sandwich-query-i)', { desc = 'Sandwich: Inner query block' })
    vim.keymap.set('o', 'as', '<Plug>(textobj-sandwich-query-a)', { desc = 'Sandwich: Around query block' })
    vim.keymap.set('x', 'as', '<Plug>(textobj-sandwich-query-a)', { desc = 'Sandwich: Around query block' })
  end,
}
