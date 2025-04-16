-- return {
--   'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
--   config = function()
--     -- Function to toggle diagnostics
--     local function toggle_diagnostics()
--       diagnostic_enabled = not diagnostic_enabled
--       if diagnostic_enabled then
--         -- Enable diagnostics
--         vim.diagnostic.enable()
--         vim.diagnostic.config {
--           virtual_text = false,
--           virtual_lines = {
--             only_current_line = true,
--           },
--         }
--       else
--         -- Disable diagnostics
--         vim.diagnostic.enable(false)
--       end
--     end
--
--     -- -- Set the keybinding (using <leader>td for "toggle diagnostics")
--     vim.keymap.set('n', '<leader>dt', toggle_diagnostics, {
--       desc = 'Toggle diagnostics',
--       silent = true,
--       noremap = true,
--     })
--     toggle_diagnostics()
--   end,
-- }
--
return {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'VeryLazy', -- Or `LspAttach`
  priority = 1000, -- needs to be loaded in first
  config = function()
    require('tiny-inline-diagnostic').setup {
      preset = 'powerline',
    }
    vim.diagnostic.config { virtual_text = false } -- Only if needed in your configuration, if you already have native LSP diagnostics
  end,
}
