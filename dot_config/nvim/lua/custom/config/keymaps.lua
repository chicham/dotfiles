-- Global keymaps: the ones that belong to Neovim itself rather than to a
-- plugin. Anything a plugin owns is declared in that plugin's `keys` table so
-- it can also serve as the load trigger.

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Diagnostic keymaps
-- Read live state (vim.diagnostic.is_enabled) as the source of truth so this
-- toggle stays in sync with anything else that flips diagnostics (e.g. the
-- CoderPad practice mode in lua/custom/coderpad.lua).
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
-- The `zt` suffix on the three that change which window is current scrolls the
-- landing window so the cursor line is at the top: after a split or a cycle the
-- interesting line is usually the one you were on, not the middle of the file.
vim.keymap.set("n", "<leader>ww", "<C-w><C-w>zt", { silent = true, desc = "Cycle to next window" })
vim.keymap.set("n", "<leader>wv", "<C-w>vzt", { silent = true, desc = "Split vertical" })
vim.keymap.set("n", "<leader>wh", "<C-w>szt", { silent = true, desc = "Split horizontal" })
vim.keymap.set("n", "<leader>wc", "<C-w>c", { desc = "Close window" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalise window sizes" })
vim.keymap.set("n", "<leader>wr", "<C-w>r", { desc = "Rotate windows" })
vim.keymap.set("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })
vim.keymap.set("n", "<leader><Up>", "<C-w><Up>", { desc = "Window above" })
vim.keymap.set("n", "<leader><Down>", "<C-w><Down>", { desc = "Window below" })
vim.keymap.set("n", "<leader><Right>", "<C-w><Right>", { desc = "Window right" })
vim.keymap.set("n", "<leader><Left>", "<C-w><Left>", { desc = "Window left" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right window" })

-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { silent = true, desc = "Previous buffer" })

-- Better movement on wrapped lines
-- Countless j/k walk display lines so a wrapped paragraph moves one screen row
-- at a time; with a count they stay linewise, so `5j` and relative-number jumps
-- land where the number says.
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up (display line)" })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down (display line)" })

-- Macro helpers
vim.keymap.set("n", "Q", "@@", { desc = "Replay last macro" })
vim.keymap.set("x", "Q", ":normal @@<CR>", { desc = "Replay last macro on each line" })

-- Write buffer
vim.keymap.set("n", "W", ":w<cr>", { silent = true, desc = "Write buffer" })

-- Utility shortcuts.
-- No <leader>q: it is the prefix of quicker.nvim's <leader>qq / <leader>ql,
-- so binding it would make every quit wait out `timeoutlen`. `:q` is one
-- keystroke longer and unambiguous.
vim.keymap.set("n", "<leader>Q", ":qa!<CR>", { silent = true, desc = "Force quit all" })

-- Tab controls
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { silent = true, desc = "New tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { silent = true, desc = "Close tab" })
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { silent = true, desc = "Close other tabs" })

-- Visual mode indent fix
-- Reselect after indenting so a run of < or > does not need `gv` between each.
vim.keymap.set("x", "<", "<gv", { desc = "Dedent and reselect" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent and reselect" })

-- Move text up and down
vim.keymap.set("x", "J", ":m .+1<CR>==", { silent = true, desc = "Move selection down" })
vim.keymap.set("x", "K", ":m .-2<CR>==", { silent = true, desc = "Move selection up" })
-- Delete into the black hole register first, so the unnamed register still
-- holds what was yanked and the same text can be pasted over again.
vim.keymap.set("x", "p", '"_dP', { silent = true, desc = "Paste over selection, keep register" })

-- Keep cursor centered when jumping
-- Set a mark before the join and jump back to it, so joining a run of lines
-- does not walk the cursor rightwards through the growing line.
vim.keymap.set("n", "J", "mzJ`z", { silent = true, desc = "Join line, keep cursor" })

-- Miscellaneous keymaps
vim.keymap.set(
  "n",
  "<leader>pp",
  ":let @+ = join([expand('%:p'), line('.')], ':')<cr>",
  { silent = true, desc = "Copy path:line to clipboard" }
)

-- `0` reaches the first non-blank, which is the column wanted almost every
-- time, on the key that is easiest to hit. The trade-off is that normal-mode
-- `0` can no longer reach column 0; `|` still does, and operators keep the
-- real thing through `d0` / `y0`.
vim.keymap.set("n", "0", "^", { desc = "First non-blank character" })
