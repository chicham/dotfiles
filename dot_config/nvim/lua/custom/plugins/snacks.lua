-- snacks.nvim, for the modules mini has no equivalent for.
--
-- Which collection a module comes from is decided by: mini first; snacks only
-- for what mini lacks and that earns its place on evidence; never a module of
-- either that duplicates an installed plugin. The picker in particular stays
-- off -- it would sit alongside fzf-lua and split the config across two finder
-- UIs -- as do `explorer` (oil), `notifier` (fidget), and `indent`/`scope`,
-- which draw in the buffer and collide with mini.indentscope.
--
-- `input` provides `vim.ui.input`. fzf-lua already owns `vim.ui.select` (see
-- fzf-lua.lua) but is a finder and cannot supply `vim.ui.input`, which
-- otherwise falls back to the command line. jj.nvim asks for text through it in
-- fifteen places -- describe, revset entry in the log buffer, bookmark and tag
-- names -- so every one of those becomes a float at the cursor. It does not
-- reach quickfix-review's comment box or anything else built on `vim.fn.input`,
-- which no ui plugin can intercept.
--
-- `words` highlights every reference to the symbol under the cursor and moves
-- between them with `]]`/`[[`. It replaces the kickstart CursorHold autocmds
-- that used to live in init.lua: same `vim.lsp.buf.document_highlight` call
-- underneath, but triggered on CursorMoved with a debounce rather than after
-- `updatetime`, and it adds the navigation. vimtex binds `]]`/`[[` too, but
-- buffer-locally in tex buffers, so those win where they apply.
--
-- `dim` is the focus/spotlight: it dims code outside the cursor's treesitter
-- scope, keeping it visible (unlike origami's folds) but low-contrast. It is a
-- library module -- listed in `opts` only so the settings below are picked up
-- by `Snacks.dim.enable()`; nothing starts it automatically, and `<leader>zf`
-- is the only way in.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "]]",
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = "Next reference",
      mode = { "n", "t" },
    },
    {
      "[[",
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = "Prev reference",
      mode = { "n", "t" },
    },
    {
      "<leader>zf",
      function()
        if Snacks.dim.enabled then
          Snacks.dim.disable()
        else
          Snacks.dim.enable()
        end
      end,
      desc = "Dim out-of-scope",
    },
  },
  opts = {
    input = { enabled = true },
    words = { enabled = true },

    dim = {
      scope = {
        -- Line window used when no `blocks` node matches, the equivalent of
        -- twilight's `context`.
        max_size = 10,
        treesitter = {
          enabled = true,
          -- `blocks.enabled` defaults to false, at which point the node list
          -- below is ignored entirely and dimming silently degrades to the
          -- flat `max_size` window.
          blocks = {
            enabled = true,
            -- Matched by exact node type, and the names differ per grammar, so
            -- both languages are listed explicitly.
            -- python (jax/flax)
            "function_definition",
            "class_definition",
            "decorated_definition", -- keep @nn.compact / @jax.jit decorated fns lit
            "if_statement",
            "for_statement",
            "while_statement",
            "with_statement",
            "dictionary", -- python's equivalent of lua's table_constructor
            -- lua (this config)
            "function_declaration",
            "table_constructor",
            "function_call", -- require(...).setup({ ... }) plugin specs stay lit
          },
        },
      },
      -- Buffers without a parser have nothing to scope to, and the default
      -- filter only checks `buftype`.
      filter = function(buf)
        local skip = {
          text = true,
          txt = true,
          help = true,
          markdown = true,
          lazy = true,
          qf = true,
          TelescopePrompt = true,
          oil = true,
        }
        return vim.g.snacks_dim ~= false
          and vim.b[buf].snacks_dim ~= false
          and vim.bo[buf].buftype == ""
          and not skip[vim.bo[buf].filetype]
      end,
    },
  },
}
