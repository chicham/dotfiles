-- Syntax-highlights the body of a MyST notebook's `{code-cell}` blocks by the
-- cell's own language, which plain markdown highlighting does not do -- the
-- directive is opaque to it, so the code inside renders as prose.
-- jupytext.lua covers `.ipynb`; this covers the MyST-flavoured markdown form.
return {
  "sondalex/mystnb.nvim",
  ft = { "markdown", "myst" },
  config = function()
    require("mystnb").setup()
  end,
}
