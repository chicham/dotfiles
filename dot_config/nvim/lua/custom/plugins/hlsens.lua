-- Search-position lens: `n` / `N` show how many matches there are and where in
-- the run the cursor sits, in virtual text beside the match.
return {
  -- Short form, matching how better-n.lua names the same plugin in its
  -- `dependencies`. lazy.nvim merges the two specs by derived name either way,
  -- but one spelling is one plugin.
  "kevinhwang91/nvim-hlslens",
  -- Reached only through better-n's n/N mappings, which declare it as a
  -- dependency; this spec exists to carry the options, not a trigger.
  lazy = true,
  opts = {
    calm_down = true,
    nearest_only = true,
  },
}
