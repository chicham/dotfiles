-- Surround (replaces machakann/vim-sandwich). Standalone mini module, configured
-- to mirror tpope/vim-surround's mappings (operator-key prefixes, no s-prefix):
--   ds<pair>        delete surrounding    -- ds)  ds"  ds}  ds`
--   cs<old><new>    change surrounding    -- cs)] turns (..) into [..]
--   ys<motion><p>   add surrounding       -- ysiw"  surround word with "
--   yss<pair>       add around the line   -- yss)
--   S<pair>         add around selection  -- visual mode
-- The `s` key stays free for leap/substitute; surround hangs off d/c/y instead.
return {
  "echasnovski/mini.surround",
  version = false,
  keys = {
    { "ys", mode = "n", desc = "Add surround" },
    { "ds", mode = "n", desc = "Delete surround" },
    { "cs", mode = "n", desc = "Change surround" },
    { "S", mode = "x", desc = "Add surround (visual)" },
  },
  opts = {
    -- Search not only the covering pair but also the nearest one around.
    search_method = "cover_or_next",
    -- Built-in aliases already cover a whole category with one key:
    --   b = any bracket  () [] {}      (dsb / csb<new>)
    --   q = any quote    ' " `         (dsq / csq<new>)
    -- `a` ("any") below goes further: one key for brackets AND quotes together,
    -- so dsa deletes whatever pair is nearest without naming its type, and
    -- csa<new> changes it. Output defaults to () for when `a` is the *target*.
    custom_surroundings = {
      ["a"] = {
        input = { { "%b()", "%b[]", "%b{}", "'.-'", '".-"', "`.-`" }, "^.().*().$" },
        output = { left = "(", right = ")" },
      },
    },
    -- vim-surround layout. Unused features get an empty string to leave their
    -- default s-prefixed keys unmapped.
    mappings = {
      add = "ys",
      delete = "ds",
      replace = "cs",
      find = "",
      find_left = "",
      highlight = "",
      update_n_lines = "",
      suffix_last = "",
      suffix_next = "",
    },
  },
  config = function(_, opts)
    require("mini.surround").setup(opts)

    -- mini maps `ys` in Visual mode too; vim-surround uses `S` there instead.
    pcall(vim.keymap.del, "x", "ys")
    vim.keymap.set(
      "x",
      "S",
      [[:<C-u>lua MiniSurround.add('visual')<CR>]],
      { silent = true, desc = "Add surround (visual)" }
    )

    -- `yss<pair>` surrounds the whole line, like vim-surround (`_` is the linewise
    -- textobject); remap so it routes through the `ys` operator.
    vim.keymap.set("n", "yss", "ys_", { remap = true, desc = "Add surround around line" })
  end,
}
