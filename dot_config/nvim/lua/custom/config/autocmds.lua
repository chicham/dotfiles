-- Autocommands that belong to the editor rather than to any plugin.

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Remember cursor position when reopening files.
--
-- The `'\"` mark is per-file and outlives the buffer, so for a file whose
-- contents are rewritten between opens -- a commit or rebase message, a jj
-- description -- it points into the *previous* text and lands the cursor
-- somewhere arbitrary in the new one. Those buffers want the top of the file.
-- Anything that is not an ordinary file buffer has no saved position worth
-- restoring either.
local skip_cursor_restore = {
  gitcommit = true,
  gitrebase = true,
  jjdescription = true,
}
--
-- On `BufWinEnter` rather than `BufReadPost`: `filetype` is still empty at
-- BufReadPost -- FileType fires after it -- so an exclusion list read there
-- never matches anything. BufWinEnter runs once the buffer is in a window and
-- detected, and the buffer flag keeps it to the first time.
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = function(args)
    if vim.b[args.buf].cursor_restored then
      return
    end
    vim.b[args.buf].cursor_restored = true
    if vim.bo[args.buf].buftype ~= "" or skip_cursor_restore[vim.bo[args.buf].filetype] then
      return
    end
    local line = vim.fn.line
    if line("'\"") > 0 and line("'\"") <= line("$") then
      vim.cmd('normal! g`"')
    end
  end,
})

-- Auto-resize panes on terminal resize
vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})
