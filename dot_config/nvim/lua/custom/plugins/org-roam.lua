-- org-roam.nvim configuration
-- PKM (Personal Knowledge Management) and Journaling System
--
-- USAGE GUIDE:
--
-- Knowledge Base Commands:
--   <Leader>nf - Find or create node
--   <Leader>nc - Capture new note
--   <Leader>nb - Show backlinks
--   <Leader>ni - Insert link to another node
--
-- Journaling Commands:
--   <Leader>ndN - Capture today's daily note
--   <Leader>ndn - Go to today's note
--   <Leader>ndp - Go to previous day's note
--   <Leader>ndt - Go to tomorrow's note
--
-- Workflow Examples:
--   1. Create a new note: <Leader>nc (enter title)
--   2. Link to existing notes: Type [[ and use completion
--   3. Find related content: <Leader>nb to see backlinks
--   4. Daily journaling: <Leader>ndn (start today's entry)
--
-- See full documentation at: https://github.com/chipsenkbeil/org-roam.nvim

return {
  "chipsenkbeil/org-roam.nvim",
  tag = "0.1.1",
  dependencies = {
    "nvim-orgmode/orgmode",
  },
  config = function()
    require("org-roam").setup({
      -- Main directory for org-roam files
      directory = "~/.orgfiles/roam",

      -- Make use of existing org-files from orgmode
      org_files = {
        "~/.orgfiles/gtd/*.org",
        "~/.orgfiles/research/*.org",
      },

      -- Configure daily notes for journaling
      dailies = {
        directory = "~/.orgfiles/roam/daily/",
        file_format = "%Y-%m-%d.org",
      },

      -- Default template content
      templates = {
        -- Default template for new notes
        default = [[
* %?
:PROPERTIES:
:ID: %(org-id-uuid)
:CREATED: %U
:END:
]],
        -- Template for daily notes (journaling)
        daily = [[
* %<%Y-%m-%d> Daily Journal
:PROPERTIES:
:ID: %(org-id-uuid)
:END:

** Morning Reflection
%?

** Goals for Today
- [ ]

** Progress on Projects

** Evening Review
]],
      },

      -- Completion settings
      completion = {
        nvim_cmp = true,
        trigger_chars = { "[" },
      },

      -- Node properties to display in the UI
      ui = {
        display_properties = {
          "title",
          "id",
          "file",
          "tags",
          "created",
        },
      },
    })

    -- Keybindings for org-roam
    local keymap = vim.keymap.set

    -- Node navigation and management
    keymap("n", "<leader>nf", "<cmd>lua require('org-roam').find_node()<CR>", { desc = "Find or create node" })
    keymap("n", "<leader>nc", "<cmd>lua require('org-roam').capture()<CR>", { desc = "Capture new note" })
    keymap("n", "<leader>nb", "<cmd>lua require('org-roam').backlinks()<CR>", { desc = "Show backlinks" })
    keymap("n", "<leader>ni", "<cmd>lua require('org-roam').insert_link()<CR>", { desc = "Insert link" })

    -- Daily journaling keybindings
    keymap("n", "<leader>ndN", "<cmd>lua require('org-roam').capture_today()<CR>", { desc = "Capture today's daily note" })
    keymap("n", "<leader>ndn", "<cmd>lua require('org-roam').find_daily()<CR>", { desc = "Go to today's note" })
    keymap("n", "<leader>ndp", "<cmd>lua require('org-roam').find_daily(-1)<CR>", { desc = "Go to previous day's note" })
    keymap("n", "<leader>ndt", "<cmd>lua require('org-roam').find_daily(1)<CR>", { desc = "Go to tomorrow's note" })

    -- Integrate org-roam with nvim-cmp for completion
    local has_cmp, cmp = pcall(require, "cmp")
    if has_cmp then
      local sources = cmp.get_config().sources
      table.insert(sources, { name = "org-roam" })
      cmp.setup({ sources = sources })
    end
  end,
}
