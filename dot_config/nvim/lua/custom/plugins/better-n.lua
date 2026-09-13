return {
  "jonatan-branting/nvim-better-n",
  dependencies = { "kevinhwang91/nvim-hlslens" },
  -- Not `keys = { "n", "N" }`: create() works by watching every keystroke
  -- through vim.on_key, so the plugin has to already be running when the
  -- motion that n repeats is typed. Loading it on the first n means that
  -- press has nothing recorded to repeat and falls through to a plain search.
  -- VeryLazy is the earliest trigger that is still off the startup path but
  -- guaranteed to fire before any input.
  event = "VeryLazy",
  config = function()
    local better_n = require("better-n")
    better_n.setup({
      disable_default_mappings = true,
    })

    -- Use the new API to create mappings with centering and hlslens integration
    better_n.create({
      next = "n",
      previous = "N",
      after = 'zzzv<Cmd>lua require("hlslens").start()<CR>',
    })
  end,
}
