-- The LSP stack: mason, the server definitions, and the buffer-local
-- keymaps and options installed when a server attaches.
return {
  -- Main LSP Configuration
  "neovim/nvim-lspconfig",
  -- Load on first real buffer instead of at startup: mason, the server
  -- definitions and mason-tool-installer's registry sync all run inside
  -- config(), so deferring to BufReadPre/BufNewFile takes the whole block
  -- off the startup critical path (it still fires before the first file's
  -- FileType, so the server attaches to that buffer as usual).
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim.
    -- mason.nvim + mason-lspconfig moved to the mason-org org
    -- (williamboman/* now just redirects). mason-tool-installer is a
    -- separate project and stays at WhoIsSethDaniel.
    { "mason-org/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    -- Useful status updates for LSP.
    { "j-hui/fidget.nvim", opts = {} },

    -- Allows extra capabilities provided by blink.cmp
    "saghen/blink.cmp",
  },
  config = function()
    --  This function gets run when an LSP attaches to a particular buffer.
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        -- LSP keymaps
        -- Note: the goto pickers live on <leader>g*, handled by fzf-lua
        -- Note: <leader>cf (format) is handled by conform.nvim, see its keys spec
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("gK", vim.lsp.buf.signature_help, "Signature Documentation")
        map("<space>D", vim.lsp.buf.type_definition, "Type Definition")
        -- Rename and code action live under <leader>r, not <leader>c: the
        -- whole <leader>c space belongs to quickfix-review, whose maps are
        -- global while these are buffer-local, so an LSP buffer would
        -- silently shadow the review commands wherever the two overlap.
        -- Expr rhs so the cmdline opens prefilled with the word under the
        -- cursor; inc-rename previews the edit live and applies it on <CR>.
        vim.keymap.set("n", "<leader>rn", function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end, { buffer = event.buf, expr = true, desc = "LSP: [R]e[n]ame" })
        map("<leader>ra", vim.lsp.buf.code_action, "[R]efactor [A]ction")
        -- Better diagnostic navigation
        vim.keymap.set("n", "[d", function()
          vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
        end, { desc = "Previous error" })

        vim.keymap.set("n", "]d", function()
          vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
        end, { desc = "Next error" })

        vim.keymap.set("n", "[w", function()
          vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN, float = true })
        end, { desc = "Previous warning" })

        vim.keymap.set("n", "]w", function()
          vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN, float = true })
        end, { desc = "Next warning" })

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- Reference highlighting under the cursor is snacks.words' job (see
        -- snacks.lua); it attaches on LspAttach itself and needs nothing here.

        -- Inlay hints toggle keymap
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map("<leader>ch", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
          end, "Code Toggle Inlay [H]ints")
        end
      end,
    })

    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- Define servers
    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      },
      rust_analyzer = {},
      ty = {},
      texlab = {
        settings = {
          texlab = {
            build = {
              onSave = false,
            },
            forwardSearch = {
              executable = "skim",
              args = { "-g", "%l", "%f" },
            },
          },
        },
      },
      copilot = {},
    }

    -- Additional LSPs for macOS
    servers.bashls = {}
    servers.clangd = {}
    servers.cssls = {}
    servers.html = {}
    servers.jsonls = {}

    -- Ensure Mason is set up
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- Set up servers using mason
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      "stylua", -- Used to format Lua code
      "shellcheck",
    })
    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

    -- mason-lspconfig v2 removed the `handlers` field, so per-server settings
    -- and completion capabilities must be registered via the native vim.lsp API
    -- before servers are auto-enabled.
    vim.lsp.config("*", { capabilities = capabilities })
    for server_name, server in pairs(servers) do
      vim.lsp.config(server_name, server)
    end

    -- No `ensure_installed` here: mason-tool-installer above already installs
    -- every server in `servers` (it was drifting from this list anyway).
    -- automatic_enable turns on whatever mason has installed.
    require("mason-lspconfig").setup({
      automatic_enable = true,
    })
  end,
}
