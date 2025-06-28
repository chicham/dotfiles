return {
  'markonm/traces.vim',
  event = 'CmdlineEnter',
  config = function()
    vim.g.traces_abolish_integration = 2
  end,
}
