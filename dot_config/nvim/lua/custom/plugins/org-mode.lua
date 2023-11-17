return {
  "https://github.com/nvim-orgmode/orgmode",
  dependencies = {
    "https://github.com/akinsho/org-bullets.nvim",
    "https://github.com/joaomsa/telescope-orgmode.nvim",
  },
  config = function()
    require("orgmode").setup({
      org_agenda_files = { "~/.orgmode/**/*" },
      org_default_notes_file = "~/.orgmode/todo.org",
      org_todo_keywords = { "TODO(t)", "WAITING(w)", "|", "DONE(d)", "CANCELED(c)" },
      org_agenda_skip_scheduled_if_done = true,
      org_capture_templates = {
        t = { description = "Task", template = "* TODO %?", target = "~/.orgmode/todo.org" },
        s = { description = "SubTask", template = "- [ ] %?", target = "~/.orgmode/todo.org" },
        c = { description = "Coding Task", template = "* TODO %?\n  %a", target = "~/.orgmode/todo.org" },
        j = {
          description = "Journal",
          template = "\n* %<%Y-%m-%d> %<%A>\n - %?",
          target = "~/.orgmode/journal.org",
        },
        e = {
          description = "Journal entry",
          template = " - %?",
          target = "~/.orgmode/journal.org",
        },
      },
      mappings = {
        capture = {
          org_capture_finalize = "<Leader>w",
        },
        note = {
          org_note_finalize = "<Leader>w",
        },
        org = {
          org_toggle_checkbox = "cix",
          org_promote_subtree = "<<",
          org_demote_subtree = ">>",
          org_edit_special = "<Leader>os",
        },
      },
    })
    require("orgmode").setup_ts_grammar()
    require("org-bullets").setup({
      symbols = {
        list = "󱘹",
        headlines = { "" },
        checkboxes = {
          half = { "󰡖", "OrgTSCheckboxHalfChecked" },
          done = { "󰸞", "OrgDone" },
          todo = { "", "OrgTODO" },
        },
      },
    })
    require("telescope").load_extension("orgmode")
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "org",
      group = vim.api.nvim_create_augroup("orgmode_telescope_nvim", { clear = true }),
      callback = function()
        vim.keymap.set("n", "<leader>or", require("telescope").extensions.orgmode.refile_heading)
      end,
    })
    vim.keymap.set(
      "n",
      "<leader>fo",
      require("telescope").extensions.orgmode.search_headings,
      { desc = "Find [C]ommands" }
    )
  end,
}
