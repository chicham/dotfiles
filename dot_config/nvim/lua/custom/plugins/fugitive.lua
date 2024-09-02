-- return {
--   'tpope/vim-fugitive',
--   keys = {
--     -- Git commands
--     { '<leader>gg', ':0Git<CR>', desc = 'Open Git status', { silent = true } },
--     { '<leader>gw', ':Gwrite<CR>', desc = 'Write changes to Git' },
--     { '<leader>gW', ':Gwrite!<CR>', desc = 'Force write changes to Git' },
--     { '<leader>g+', ':Git stash<CR>:e<CR>', desc = 'Stash changes and reopen buffer' },
--     { '<leader>g-', ':Git stash pop<CR>:e<CR>', desc = 'Pop stash and reopen buffer' },
--     {
--       '<leader>go',
--       function()
--         vim.cmd(string.format '.,GBrowse')
--       end,
--       desc = 'Open current line in Git browser',
--       expr = true,
--     },
--     { '<leader>gl', ':Gllog<CR>', desc = 'View Git log' },
--
--     -- Telescope integration (requires telescope.nvim)
--     { '<leader>gs', require('telescope.builtin').git_stash, desc = 'Browse Git stashes with Telescope' },
--     { '<leader>gc', require('telescope.builtin').git_commits, desc = 'Browse Git commits with Telescope' },
--   },
-- }
--
return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed, not both.
    'nvim-telescope/telescope.nvim', -- optional
  },
  config = true,
  keys = {
    -- Open Neogit status window
    { '<leader>gg', '<cmd>Neogit<CR>', desc = 'Open Neogit status' },

    -- Stage/Unstage file (similar to :Gwrite)
    { '<leader>gw', '<cmd>Neogit stage<CR>', desc = 'Stage file' },

    -- No direct equivalent for force write in Neogit

    -- Stash/Pop (using Neogit commands)
    { '<leader>g+', '<cmd>Neogit stash push<CR>', desc = 'Create stash' },
    { '<leader>g-', '<cmd>Neogit stash pop<CR>', desc = 'Pop stash' },

    -- Open commit in browser (no direct equivalent, but you could customize Neogit)

    -- View Git log
    { '<leader>gl', '<cmd>Neogit log<CR>', desc = 'View Git log' },

    -- Telescope integration (requires telescope-frecency.nvim)
    -- These remain the same as they use Telescope commands
    { '<leader>gs', '<cmd>Telescope frecency workspace=git_stash<CR>', desc = 'Browse Git stashes with Telescope' },
    { '<leader>gc', '<cmd>Telescope frecency workspace=git_commits<CR>', desc = 'Browse Git commits with Telescope' },
  },
}
