-- Teaches the Lua language server about the Neovim runtime and the plugins on
-- the runtimepath, so editing this config gets completion and diagnostics for
-- the `vim` API.
return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
