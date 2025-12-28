return {
  'jonatan-branting/nvim-better-n',
  dependencies = { 'kevinhwang91/nvim-hlslens' },
  config = function()
    local better_n = require('better-n')
    better_n.setup {
      disable_default_mappings = true,
    }

    -- Use the new API to create mappings with centering and hlslens integration
    better_n.create {
      next = 'n',
      previous = 'N',
      after = 'zzzv<Cmd>lua require("hlslens").start()<CR>',
    }
  end,
}
