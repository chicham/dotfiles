return {
  'tpope/vim-fugitive',
  lazy = false,
  keys = {
    -- Git commands
    -- { '<leader>gg', ':0Git<CR>', desc = 'Open Git status', { silent = true } },
    { '<leader>gw', ':Gwrite<CR>', desc = 'Write changes to Git' },
    { '<leader>gW', ':Gwrite!<CR>', desc = 'Force write changes to Git' },
    { '<leader>g+', ':Git stash<CR>:e<CR>', desc = 'Stash changes and reopen buffer' },
    { '<leader>g-', ':Git stash pop<CR>:e<CR>', desc = 'Pop stash and reopen buffer' },
    { '<leader>gd', ':Gvdiffsplit!<CR>', desc = 'Open 3-ways diffsplit' },
    {
      '<leader>go',
      function()
        vim.cmd(string.format '.,GBrowse')
      end,
      desc = 'Open current line in Git browser',
      expr = true,
    },

    -- Git commands
  },
}
