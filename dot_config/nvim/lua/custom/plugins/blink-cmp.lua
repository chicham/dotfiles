-- Completion: the popup menu, its sources and its keymap.
return {
  "saghen/blink.cmp",
  -- Completion cannot be needed before there is an insert or a command line.
  -- Opening a file still loads it earlier than this, via nvim-lspconfig's
  -- dependency on it for get_lsp_capabilities() -- which is what keeps the
  -- capabilities correct -- so this only matters to sessions that never edit.
  event = { "InsertEnter", "CmdlineEnter" },
  version = "1.*",
  dependencies = {
    -- Snippet Engine
    {
      "L3MON4D3/LuaSnip",
      version = "2.*",
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
          return
        end
        return "make install_jsregexp"
      end)(),
      opts = {},
    },
    "folke/lazydev.nvim",
    "fang2hou/blink-copilot",
    { "saghen/blink.compat", opts = {} },
  },
  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  opts = {
    enabled = function()
      return not vim.b.blink_disable and not vim.g.blink_disable
    end,
    keymap = {
      preset = "none",
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },

    appearance = {
      nerd_font_variant = "mono",
    },

    completion = {
      list = { selection = { preselect = false, auto_insert = false } },
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { "copilot", "lsp", "path", "snippets", "lazydev", "buffer", "orgmode" },
      providers = {
        lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          score_offset = 100,
          async = true,
        },
        orgmode = {
          name = "orgmode",
          module = "blink.compat.source",
        },
      },
    },

    snippets = { preset = "luasnip" },

    fuzzy = { implementation = "lua" },

    signature = { enabled = true },
  },
}
