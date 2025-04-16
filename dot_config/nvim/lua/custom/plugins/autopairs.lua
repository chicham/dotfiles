return {
  'windwp/nvim-autopairs',
  dependencies = { 'hrsh7th/nvim-cmp', 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('nvim-autopairs').setup {
      -- ignored_next_char = '[%w%.]',
      check_ts = true,
      ts_config = {
        lua = { 'string' },
        javascript = { 'template_string' },
        java = false,
      },
    }

    -- Integrate with nvim-cmp
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}
