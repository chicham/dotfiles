return {
  "jonatan-branting/nvim-better-n",
  dependencies = { "kevinhwang91/nvim-hlslens" },
  -- The plugin exists to redefine n and N, so those keys are also the only way
  -- to need it. lazy holds them until the first press, then replays into the
  -- mappings config() installs -- which is what pulls in hlslens too.
  keys = { "n", "N" },
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
