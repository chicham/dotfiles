-- Global keymaps: the ones that belong to Neovim itself rather than to a
-- plugin. Anything a plugin owns is declared in that plugin's `keys` table so
-- it can also serve as the load trigger.

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
-- Read live state (vim.diagnostic.is_enabled) as the source of truth so this
-- toggle stays in sync with anything else that flips diagnostics (e.g. the
-- CoderPad practice mode defined at the bottom of this file).
local function toggle_diagnostics()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end

vim.keymap.set("n", "<leader>dt", toggle_diagnostics, {
  desc = "Toggle diagnostics",
  silent = true,
  noremap = true,
})

-- Exit terminal mode in the builtin terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Windows management
vim.keymap.set("n", "<leader>ww", "<C-w><C-w>zt", { silent = true })
vim.keymap.set("n", "<leader>wv", "<C-w>vzt", { silent = true })
vim.keymap.set("n", "<leader>wh", "<C-w>szt", { silent = true })
vim.keymap.set("n", "<leader>wc", "<C-w>c")
vim.keymap.set("n", "<leader>w=", "<C-w>=")
vim.keymap.set("n", "<leader>wr", "<C-w>r")
vim.keymap.set("n", "<leader>wo", "<C-w>o")
vim.keymap.set("n", "<leader><Up>", "<C-w><Up>")
vim.keymap.set("n", "<leader><Down>", "<C-w><Down>")
vim.keymap.set("n", "<leader><Right>", "<C-w><Right>")
vim.keymap.set("n", "<leader><Left>", "<C-w><Left>")

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right window" })

-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { silent = true })

-- Better movement on wrapped lines
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Macro helpers
vim.keymap.set("n", "Q", "@@")
vim.keymap.set("x", "Q", ":normal @@<CR>")

-- Write buffer
vim.keymap.set("n", "W", ":w<cr>", { silent = true })

-- Utility shortcuts
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true }) -- Quick quit
vim.keymap.set("n", "<leader>Q", ":qa!<CR>", { silent = true }) -- Force quit all

-- Tab controls
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { silent = true }) -- New tab
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { silent = true }) -- Close tab
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { silent = true }) -- Close other tabs

-- Visual mode indent fix
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

-- Move text up and down
vim.keymap.set("x", "J", ":m .+1<CR>==", { silent = true })
vim.keymap.set("x", "K", ":m .-2<CR>==", { silent = true })
vim.keymap.set("x", "p", '"_dP', { silent = true }) -- Don't lose yanked text when pasting over selection

-- Keep cursor centered when jumping
vim.keymap.set("n", "J", "mzJ`z", { silent = true })

-- Miscellaneous keymaps
vim.keymap.set("n", "<leader>pp", ":let @+ = join([expand('%:p'), line('.')], ':')<cr>", { silent = true })
vim.keymap.set("n", "0", "^")
