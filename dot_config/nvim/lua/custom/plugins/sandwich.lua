return {
  'machakann/vim-sandwich',
  opts = {
    rtp = 'macros',
  },
  config = function()
    -- Load surround keymapping
    vim.cmd [[ runtime macros/sandwich/keymap/surround.vim ]]

    -- Enable textobj-sandwich functionality
    vim.cmd [[ runtime autoload/textobj/sandwich.vim ]]

    -- Ensure text objects are properly loaded
    vim.g.textobj_sandwich_no_default_key_mappings = 0

    -- Load the textobj mappings
    vim.cmd [[
      " Load text objects
      omap ib <Plug>(textobj-sandwich-auto-i)
      xmap ib <Plug>(textobj-sandwich-auto-i)
      omap ab <Plug>(textobj-sandwich-auto-a)
      xmap ab <Plug>(textobj-sandwich-auto-a)

      " Query-based text objects
      omap is <Plug>(textobj-sandwich-query-i)
      xmap is <Plug>(textobj-sandwich-query-i)
      omap as <Plug>(textobj-sandwich-query-a)
      xmap as <Plug>(textobj-sandwich-query-a)
    ]]
  end,
}
