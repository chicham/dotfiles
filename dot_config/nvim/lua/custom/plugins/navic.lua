-- Mouseless statusline breadcrumb (module > class > function at the cursor).
-- Pure-LSP (no treesitter), so it is unaffected by the nvim-treesitter
-- master->main migration and needs no keymaps -- it is passive display only,
-- rendered through lualine's statusline (see lualine.lua).
--
-- Note: this overlaps treesitter-context conceptually -- both surface the
-- enclosing scope, context as a sticky header at the *top* of the window,
-- navic as the breadcrumb in the *statusline*. They complement rather than
-- conflict; if the header feels redundant, drop one.
-- navic asks only for core `vim.lsp` and an LspAttach autocmd, never for the
-- nvim-lspconfig plugin, so it does not depend on it. Declaring that edge would
-- drag lspconfig (and mason and fidget behind it) in through lualine, which
-- loads at VeryLazy, defeating lspconfig's own BufReadPre trigger in sessions
-- that never open a file.
return {
  "SmiteshP/nvim-navic",
  lazy = true, -- loaded as a lualine winbar component / on LspAttach
  opts = {
    -- Attach to any LSP client exposing documentSymbol, no per-server wiring.
    lsp = { auto_attach = true },
    -- Update context off the symbol cache rather than on every CursorMoved.
    lazy_update_context = true,
    highlight = true,
    separator = "  ",
  },
}
