return {
  'sindrets/diffview.nvim',
  lazy = true,
  keys = {
    { '<leader>gd', ':DiffviewOpen<CR>', desc = 'Open Diffview' },
  },
  opts = {
    file_panel = {
      win_config = {
        position = 'left',
        width = 35,
      },
    },
    file_history_panel = {
      win_config = {
        position = 'bottom',
        height = 20,
      },
    },
    key_bindings = {
      view = {
        ['<tab>'] = 'select_next_entry',
        ['<s-tab>'] = 'select_previous_entry',
        ['gf'] = 'goto_file',
        ['<C-q>'] = 'close',
      },
      file_panel = {
        ['j'] = 'next_entry',
        ['k'] = 'prev_entry',
        ['<tab>'] = 'select_entry',
        ['<s-tab>'] = 'deselect_entry',
        ['gf'] = 'goto_file',
        ['o'] = 'open',
        ['<cr>'] = 'open',
        ['x'] = 'delete_entry',
        ['dd'] = 'delete_entry',
        ['<C-q>'] = 'close',
      },
      file_history_panel = {
        ['g!'] = 'options',
        ['<C-q>'] = 'close',
        ['j'] = 'next_entry',
        ['k'] = 'prev_entry',
        ['<tab>'] = 'select_entry',
        ['<s-tab>'] = 'deselect_entry',
        ['gf'] = 'goto_file',
        ['o'] = 'open',
        ['<cr>'] = 'open',
        ['y'] = 'copy_hash',
        ['d'] = 'delete_entry',
      },
    },
  },
}
