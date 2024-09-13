return {
  'MagicDuck/grug-far.nvim',
  config = function()
    local grug_far = require 'grug-far'
    grug_far.setup {
      engine = 'astgrep',
    }
    vim.keymap.set('n', '<leader>fs', function()
      grug_far.open { transient = true, prefills = { paths = vim.fn.expand '%' } }
    end)
    vim.keymap.set('n', '<leader>fS', function()
      grug_far.open { transient = true }
    end)
    vim.keymap.set('x', 'g/', function()
      grug_far.with_visual_selection { transient = true, { prefills = { paths = vim.fn.expand '%' } } }
    end)
  end,
}
