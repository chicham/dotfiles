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

vim.opt.diffopt = "filler,internal,algorithm:histogram,indent-heuristic"
vim.opt.conceallevel = 1

local bind = vim.keymap.set

bind("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
bind("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--Windows management
bind("n", "<leader><Bar>", "\"<C-W>v<C-W><C-w>zt\"", { expr = true, silent = true })
bind("n", "<leader>w<Bar>", "\"<C-W>v<C-W><C-w>zt\"", { expr = true, silent = true })
bind("n", "<leader>wv", "\"<C-W>v<C-W><C-w>zt\"", { expr = true, silent = true })
bind("n", "<leader>-", "\"<C-W>s<C-W><C-W>zt\"", { expr = true, silent = true })
bind("n", "<leader>w-", "\"<C-W>s<C-W><C-W>zt\"", { expr = true, silent = true })
bind("n", "<leader>_", "\"<C-W>s<C-W><C-W>zt\"", { expr = true, silent = true })
bind("n", "<leader>ws", "\"<C-W>s<C-W><C-w>zt\"", { expr = true, silent = true })
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

require("hlargs").setup()
require("todo-comments").setup({
  highlight = {
    pattern = [[.*<(KEYWORDS)(\(\w+\))=\:]],
    keyword = "bg",
    after = "empty",
  },
  search = {
    pattern = [[\b(KEYWORDS)(\(\S+\))?:]],
  },
})

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local fmt = require("luasnip.extras.fmt").fmt

-- see latex infinite list for the idea. Allows to keep adding arguments via choice nodes.
local function py_init()
  return sn(
    nil,
    c(1, {
      t(""),
      sn(1, {
        t(", "),
        i(1),
        d(2, py_init),
      }),
    })
  )
end

-- splits the string of the comma separated argument list into the arguments
-- and returns the text-/insert- or restore-nodes
local function to_init_assign(args)
  local tab = {}
  local a = args[1][1]
  if #a == 0 then
    table.insert(tab, t({ "", "\tpass" }))
  else
    local cnt = 1
    for e in string.gmatch(a, " ?([^,]*) ?") do
      if #e > 0 then
        table.insert(tab, t({ "", "\tself." }))
        -- use a restore-node to be able to keep the possibly changed attribute name
        -- (otherwise this function would always restore the default, even if the user
        -- changed the name)
        table.insert(tab, r(cnt, tostring(cnt), i(nil, e)))
        table.insert(tab, t(" = "))
        table.insert(tab, t(e))
        cnt = cnt + 1
      end
    end
  end
  return sn(nil, tab)
end

-- create the actual snippet

require("luasnip").add_snippets("python", {
  s(
    "pyinit",
    fmt([[def __init__(self{}):{}]], {
      d(1, py_init),
      d(2, to_init_assign, { 1 }),
    })
  ),
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
