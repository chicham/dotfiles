-- Set highlight on search
vim.opt.hlsearch = false

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Save undo history
vim.opt.undofile = true

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"

-- Clipboard
vim.opt.clipboard = "unnamedplus"

vim.opt.termguicolors = true

-- Set completeopt to have a better completion experience
vim.opt.completeopt = "menuone,longest,noinsert"
vim.opt.cursorline = true

vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", trail = "·" }
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = ">>"

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case --follow --hidden --glob '!.git'"
end
vim.diagnostic.config({ virtual_lines = { only_current_line = true }, virtual_text = false })

local bind = vim.keymap.set

bind("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
bind("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--Windows management
bind("n", "<leader><Bar>", "\"<C-W>v<C-W><C-w>zt\"", { expr = true, silent = true })
bind("n", "<leader>-", "\"<C-W>s<C-W><C-W>zt\"", { expr = true, silent = true })
bind("n", "<leader>_", "\"<C-W>s<C-W><C-W>zt\"", { expr = true, silent = true })
bind("n", "<leader><Up>", "<C-w><Up>")
bind("n", "<leader><Down>", "<C-w><Down>")
bind("n", "<leader><Right>", "<C-w><Right>")
bind("n", "<leader><Left>", "<C-w><Left>")
bind("n", "<leader>wc", "<C-w>c")
bind("n", "<leader>w=", "<C-w>=")
bind("n", "<leader>wr", "<C-w>r")
bind("n", "<leader>wo", "<C-w>o")

-- Macros helpers
bind("n", "Q", "@@")
-- bind("v", ".", ":normal .")
bind("v", "Q", ":normal @@")

-- Write buffer
bind("n", "W", ":w<cr>", { silent = true })

-- Visual model indent fix
bind("v", "<", "<gv")
bind("v", ">", ">gv")
bind("n", "<leader>pp", ":let @+ = join([expand('%:p'), line('.')], ':')<cr>", { silent = true })

require("mason-lspconfig").setup({
  ensure_installed = {
    rust_analyzer = {},
    pylsp = {
      plugins = {
        ruff = {
          enabled = true,
        },
      },
    },
    lua_ls = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  automatic_installation = true,
})

require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "~/.snippets/snippets" } })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
