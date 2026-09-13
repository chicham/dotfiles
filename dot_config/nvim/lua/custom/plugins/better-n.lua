return {
  "jonatan-branting/nvim-better-n",
  dependencies = { "kevinhwang91/nvim-hlslens" },
  -- Not `keys = { "n", "N" }`: the repeatable that `n` replays is registered
  -- when the search is typed, so the plugin has to already be running by then.
  -- Loading it on the first `n` means that press has nothing recorded and
  -- falls through to a plain search. VeryLazy is the earliest trigger that is
  -- still off the startup path but guaranteed to fire before any input.
  event = "VeryLazy",
  config = function()
    local better_n = require("better-n")
    -- Default mappings off: they claim f/F/t/T, which leap owns (see leap.lua).
    -- Cmdline mappings off too, because the `/` and `?` repeatables they
    -- register are replaced below by ones that recentre and redraw the lens.
    better_n.setup({
      disable_default_mappings = true,
      disable_cmdline_mappings = true,
    })

    -- `create` only builds <Plug>(better-n-#<id>-{next,previous,passthrough})
    -- and returns the handles; binding them is the caller's job. The action is
    -- a literal key sequence fed back through an <expr> mapping, so <Cmd> has
    -- to be a real terminal code rather than the five-character spelling.
    local after = vim.api.nvim_replace_termcodes([[zzzv<Cmd>lua require("hlslens").start()<CR>]], true, false, true)

    -- One repeatable per way of starting a search. Whichever ran last is what
    -- `n`/`N` replay -- that is the whole point of the plugin over a plain
    -- `nzzzv`: the search does not have to be the most recent motion.
    for _, id in ipairs({ "/", "?" }) do
      better_n.create({ id = id, next = "n" .. after, previous = "N" .. after })
    end
    for _, key in ipairs({ "*", "#" }) do
      local r = better_n.create({
        id = key,
        passthrough = key,
        next = "n" .. after,
        previous = "N" .. after,
      })
      vim.keymap.set({ "n", "x" }, key, r.passthrough, { expr = true, silent = true })
    end

    -- Normal mode only: `n` in visual and operator-pending is leap's
    -- treesitter node selection (see leap.lua). `remap` because what these
    -- return is the <Plug> name of the active repeatable.
    vim.keymap.set("n", "n", better_n.next, { expr = true, remap = true, silent = true, nowait = true })
    vim.keymap.set("n", "N", better_n.previous, { expr = true, remap = true, silent = true, nowait = true })
  end,
}
