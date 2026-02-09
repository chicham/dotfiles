-- Focus/spotlight: dims code outside the cursor's current treesitter scope,
-- keeping it visible (unlike origami's folds) but low-contrast. No mini module
-- provides this (mini.misc.zoom maximizes, it does not dim), and it does not
-- duplicate mini.indentscope (a scope *line*) or treesitter-context (a sticky
-- *header*) -- only twilight dims. Command/keymap driven, never auto-on.
return {
  'folke/twilight.nvim',
  cmd = { 'Twilight', 'TwilightEnable', 'TwilightDisable' },
  keys = {
    { '<leader>z', '<cmd>Twilight<cr>', desc = 'Twilight: dim out-of-scope' },
  },
  opts = {
    dimming = { alpha = 0.25, inactive = false },
    context = 10, -- fallback line window when no `expand` node matches
    treesitter = true,

    -- IMPORTANT: `expand` is matched by EXACT node:type() equality, and the
    -- upstream defaults ("function"/"method"/"table") do NOT exist in the
    -- python or lua grammars -- with them twilight silently degrades to the
    -- flat `context` window on our main languages. List the real node types:
    expand = {
      -- python (jax/flax)
      'function_definition',
      'class_definition',
      'decorated_definition', -- keep @nn.compact / @jax.jit decorated fns lit
      'if_statement',
      'for_statement',
      'while_statement',
      'with_statement',
      'dictionary', -- python's equivalent of the upstream default "table"
      -- lua (this config)
      'function_declaration',
      'table_constructor',
      'function_call', -- require(...).setup({ ... }) plugin specs stay lit
    },

    -- Guard the OPEN nvim-0.12 nil-parser crash (issue #54; fix PRs #55/#56
    -- still unmerged): never engage twilight on parser-less buffers.
    exclude = { 'text', 'txt', 'help', 'markdown', 'lazy', 'qf', 'TelescopePrompt', 'oil' },
  },
}
