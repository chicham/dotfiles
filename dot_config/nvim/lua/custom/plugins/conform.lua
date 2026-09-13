-- Formatting on write, and the `<leader>cf` manual format.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "[C]ode [F]ormat",
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable autoformat for languages without a well standardized
      -- coding style. Add filetypes here to opt them out.
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and "never" or "fallback",
      }
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
