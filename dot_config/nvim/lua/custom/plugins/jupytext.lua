return {
  -- directly open ipynb files as md documents
  -- and convert back behind the scenes
  'GCBallesteros/jupytext.nvim',
  config = true,
  opts = {
    style = 'percent',
    output_extension = 'py',
    force_ft = nil,
  },
}
