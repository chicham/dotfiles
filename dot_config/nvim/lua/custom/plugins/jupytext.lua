return {
  -- directly open ipynb files as md documents
  -- and convert back behind the scenes
  "GCBallesteros/jupytext.nvim",
  -- Eager, as upstream requires. The conversion has to be installed before the
  -- notebook is read, and no lazy trigger fires in time: nvim detects `.ipynb`
  -- as `json`, so a `ft = 'ipynb'` trigger never matches at all and the buffer
  -- fills with the raw notebook. The plugin is small enough that loading it
  -- unconditionally costs nothing measurable.
  lazy = false,
  opts = {
    style = "percent",
    output_extension = "py",
    force_ft = nil,
  },
}
