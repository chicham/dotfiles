return {
  'tpope/vim-fugitive',
  keys = {
    -- Git commands
    { '<leader>gg', ':0Git<CR>', desc = 'Open Git status', { silent = true } },
    { '<leader>gw', ':Gwrite<CR>', desc = 'Write changes to Git' },
    { '<leader>gW', ':Gwrite!<CR>', desc = 'Force write changes to Git' },
    { '<leader>g+', ':Git stash<CR>:e<CR>', desc = 'Stash changes and reopen buffer' },
    { '<leader>g-', ':Git stash pop<CR>:e<CR>', desc = 'Pop stash and reopen buffer' },
    {
      '<leader>go',
      function()
        vim.cmd(string.format '.,GBrowse')
      end,
      desc = 'Open current line in Git browser',
      expr = true,
    },
    { '<leader>gl', ':Gllog<CR>', desc = 'View Git log' },

    -- Telescope integration (requires telescope.nvim)
    { '<leader>gs', require('telescope.builtin').git_stash, desc = 'Browse Git stashes with Telescope' },
    { '<leader>gc', require('telescope.builtin').git_commits, desc = 'Browse Git commits with Telescope' },
  },
}
