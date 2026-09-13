-- Turns an LSP rename into a live preview: `:IncRename <new>` highlights every
-- occurrence the server would change, updating as the name is typed, and only
-- applies the workspace edit on <CR>. `vim.lsp.buf.rename` shows nothing until
-- it has already rewritten the files.
--
-- The `<leader>rn` that reaches this lives in lspconfig.lua's LspAttach: it is
-- buffer-local, so the mapping exists only where a server can answer it.
return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  opts = {},
}
