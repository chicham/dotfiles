-- Autocommands that belong to the editor rather than to any plugin.

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Remember cursor position when reopening files
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
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
