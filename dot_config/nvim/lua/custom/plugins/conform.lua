-- Formatting on write, and the `<leader>bf` manual format.
--
-- `<leader>b` rather than `<leader>c`: `<leader>c` belongs to
-- quickfix-review's comment maps, which is where the fingers go during a
-- review, and a format is a buffer-wide action rather than a comment.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>bf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "[B]uffer [F]ormat",
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable autoformat for languages without a well standardized
      -- coding style. Add filetypes here to opt them out. Returning nil is
      -- what conform reads as "do not format"; a table always formats, and
      -- only picks whether the LSP may be the one to do it.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format", "ruff_organize_imports" },
      fish = { "fish_indent" },
      sh = { "shfmt" },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
