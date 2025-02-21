return {
  'chipsenkbeil/org-roam.nvim',
  tag = '0.1.1',
  dependencies = {
    {
      'nvim-orgmode/orgmode',
      tag = '0.3.7',
    },
  },
  config = function()
    require('org-roam').setup {
      bindings = {
        prefix = '<Leader>r',
        -- capture = '<Leader>rc',
        -- complete_at_point = '<Leader>r.',
        -- find_node = '<Leader>rf',
        -- insert_node = '<Leader>ri',
        -- insert_node_immediate = '<Leader>rm',
        -- quickfix_backlinks = '<Leader>rq',
        -- toggle_roam_buffer = '<Leader>ro',
      },
      directory = '~/.orgroam/',
      -- optional
      org_files = {
        '~/.orgfiles/',
      },
      extensions = {
        dailies = {
          directory = 'journal',
        },
      },
    }
  end,
}
