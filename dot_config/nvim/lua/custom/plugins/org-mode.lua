return {
  "nvim-orgmode/orgmode",
  opts = function()
    local orgmode = require("orgmode")
    orgmode.setup_ts_grammar()
    orgmode.setup({
      org_agenda_files = { "~/.orgmode/**/*" },
      org_default_notes_file = "~/.orgmode/inbox.org",
      org_todo_keywords = { "TODO(t)", "WAITING(w)", "NEXT(n)", "|", "DONE(d)", "CANCELED(c)" },
      org_agenda_skip_scheduled_if_done = true,
      org_indent_mode = "indent",
      win_split_mode = "float",
      org_capture_templates = {
        t = {
          description = "Task",
          subtemplates = {
            t = { description = "Task", template = "* TODO %?", target = "~/.orgmode/todo.org" },
            f = { description = "Task with file", template = "* TODO %?\n  %a", target = "~/.orgmode/todo.org" },
            s = { description = "SubTask", template = "- [ ] %?", target = "~/.orgmode/todo.org" },
          },
        },
        j = {
          description = "Journal",
          subtemplates = {
            j = {
              description = "Journal",
              template = "\n* %<%Y-%m-%d> %<%A>\n - %?",
              target = "~/.orgmode/journal/%<%Y-%m>.org",
            },
            e = {
              description = "Journal entry",
              template = " - %?",
              target = "~/.orgmode/journal/%<%Y-%m>.org",
            },
          },
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
          org_do_promote = "s[",
          org_do_demote = "s]",
          org_edit_special = "<Leader>os",
        },
      },
    })
  end,
}
