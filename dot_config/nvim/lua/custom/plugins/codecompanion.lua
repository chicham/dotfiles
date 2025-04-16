return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    config = function()
      require("codecompanion").setup({
        -- Define adapter for chat functionality
        adapters = {
          chat = "copilot", -- Use GitHub Copilot Chat adapter
        },

        -- Copilot adapter configuration
        copilot = {
          -- Don't override your existing Copilot completion setup
          override_completion = false,
          -- Use Claude 3.7 Sonnet model with extended reasoning
          model = "claude-3.7-sonnet",
        },

        -- Auto close settings
        auto_close = {
          enabled = true,
          events = { "InsertEnter" },
        },

        -- UI settings for better experience
        ui = {
          border = "rounded",
          -- Position of the chat window
          position = "bottom", -- 'top', 'right', 'bottom', 'left'
          size = {
            width = "60%",
            height = "40%",
          },
          -- Enable syntax highlighting in the chat
          highlight_prompt = true,
          -- Show model name in the prompt
          show_model = true,
        },

        -- Keymaps configuration
        keymaps = {
          -- Open the chat window
          open = "<leader>cc",
          -- Close the chat window
          close = "q",
          -- Submit the prompt
          submit = "<CR>",
          -- Use the selected text as the prompt
          use_as_input = "<CR>",
          -- Select different options
          select_up = "<C-k>",
          select_down = "<C-j>",
        },
      })
    end,
    keys = {
      {
        "<leader>cc",
        function()
          require("codecompanion").toggle()
        end,
        desc = "Toggle CodeCompanion",
      },
      {
        "<leader>ce",
        function()
          require("codecompanion").explain()
        end,
        mode = { "n", "v" },
        desc = "Explain code with CodeCompanion",
      },
      {
        "<leader>cr",
        function()
          require("codecompanion").refactor()
        end,
        mode = { "n", "v" },
        desc = "Refactor code with CodeCompanion",
      },
      {
        "<leader>cd",
        function()
          require("codecompanion").debug()
        end,
        mode = { "n", "v" },
        desc = "Debug code with CodeCompanion",
      },
      {
        "<leader>ct",
        function()
          require("codecompanion").test()
        end,
        mode = { "n", "v" },
        desc = "Generate tests with CodeCompanion",
      },
      -- Additional useful commands
      {
        "<leader>cf",
        function()
          require("codecompanion").fix()
        end,
        mode = { "n", "v" },
        desc = "Fix code with CodeCompanion",
      },
    },
  },
}
