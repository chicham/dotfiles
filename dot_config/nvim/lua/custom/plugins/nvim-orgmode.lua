-- Orgmode Configuration
--
-- USAGE GUIDE:
--
-- Capture Commands (Anywhere):
--   <Leader>oc   - Open capture menu
--
-- Capture Templates:
--   f - File Task: Capture TODO with link to current file position
--   c - Code Task: Capture TODO with selected text and file link
--   b - Bug: Create bug report with file link
--   i - Inbox: Quick capture to inbox
--   t - Scheduled Task: Task with a scheduled date
--   p - Project: Create a new project
--   s - Someday/Maybe: For future consideration
--   n - Note: Quick note
--   k - Knowledge Note: Note with ID for knowledge management
--   j - Journal Entry: Timestamped journal entry
--   S - Code Snippet: Save code with syntax highlighting
--   m - Meeting: Meeting notes template
--
-- Agenda Commands:
--   <Leader>oa   - Open agenda
--   vd          - Day view (in agenda)
--   vw          - Week view
--   vm          - Month view
--   vy          - Year view
--   L/H         - Move forward/backward in time
--
-- In Org Files:
--   <Tab>       - Cycle visibility of current heading
--   <S-Tab>     - Cycle visibility of entire buffer
--   t           - Change TODO state
--   R           - Refile current heading
--   I/O         - Clock in/out
--   <Leader>ot  - Set tags  -- codespell:ignore ot
--   <C-Space>   - Toggle checkbox
--   ]/[ + p     - Change priority up/down
--   ]/[ + d     - Change dates up/down
--   <</>        - Promote/demote heading
--
-- Usage Workflow Examples:
--   1. Capture code tasks: In code file -> <Leader>oc -> c -> Enter details
--   2. Daily review: <Leader>oa -> vd (check today's agenda)
--   3. Refile tasks: Open inbox.org -> Navigate to task -> R -> Choose destination
--   4. Knowledge management: <Leader>oc -> k -> Create titled note with ID
--
-- See full documentation at: https://github.com/nvim-orgmode/orgmode/blob/master/README.org

return {
	"nvim-orgmode/orgmode",
	ft = { "org" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		-- Setup orgmode with GTD-focused research workflow
		require("orgmode").setup({
			-- File organization for GTD + research workflow
			org_agenda_files = {
				"~/.orgfiles/gtd/inbox.org",
				"~/.orgfiles/gtd/projects.org",
				"~/.orgfiles/gtd/someday.org",
				"~/.orgfiles/gtd/tickler.org",
				"~/.orgfiles/research/*.org",
				"~/.orgfiles/roam/**/*.org",
			},
			org_default_notes_file = "~/.orgfiles/gtd/inbox.org",

			-- Enhanced capture templates for GTD with file focus
			org_capture_templates = {
				-- Quick file task (primary use case requested)
				f = {
					description = "File Task",
					template = "* TODO %? :file:\n%u\n%a", -- %a adds a link to the current file position
					target = "~/.orgfiles/gtd/inbox.org",
				},

				-- Source code specific captures
				c = {
					description = "Code Task",
					template = "* TODO %? :code:file:\n%u\n#+begin_quote\n%i\n#+end_quote\n%a", -- Includes selected text and file link
					target = "~/.orgfiles/gtd/inbox.org",
				},

				b = {
					description = "Bug",
					template = "* TODO Bug: %? :bug:file:\n%u\n%a\n** Description\n\n** Steps to Reproduce\n\n** Expected Behavior\n\n** Actual Behavior\n",
					target = "~/.orgfiles/gtd/inbox.org",
				},

				-- Other GTD workflow captures
				i = {
					description = "Inbox",
					template = "* TODO %?\n%u",
					target = "~/.orgfiles/gtd/inbox.org",
				},
				t = {
					description = "Scheduled Task",
					template = "* TODO %? \nSCHEDULED: %^t\n%u",
					target = "~/.orgfiles/gtd/tickler.org",
				},
				p = {
					description = "Project",
					template = "* %^{Project name} :project:\n%u\n** Description\n%?\n** Tasks\n\n** Notes\n",
					target = "~/.orgfiles/gtd/projects.org",
				},
				s = {
					description = "Someday/Maybe",
					template = "* %? :someday:\n%u",
					target = "~/.orgfiles/gtd/someday.org",
				},
				n = {
					description = "Note",
					template = "* %? :note:\n%u",
					target = "~/.orgfiles/gtd/inbox.org",
					headline = "Notes",
				},

				-- Knowledge Management
				k = {
					description = "Knowledge Note",
					template = "* %^{Title} :knowledge:\n:PROPERTIES:\n:ID: %(org-id-uuid)\n:CREATED: %U\n:END:\n\n%?",
					target = "~/.orgfiles/gtd/inbox.org",
					headline = "Knowledge",
				},

				-- Journal entry (for later integration with org-roam's daily notes)
				j = {
					description = "Journal Entry",
					template = "* %T Journal Entry :journal:\n%?",
					target = "~/.orgfiles/gtd/inbox.org",
					headline = "Journal",
				},

				-- Snippet capture
				S = {
					description = "Code Snippet",
					template = "* %^{Snippet title} :snippet:code:\n%u\n#+begin_src %^{Language|lua|python|bash|sh|go|rust}\n%?\n#+end_src",
					target = "~/.orgfiles/gtd/inbox.org",
					headline = "Code Snippets",
				},

				-- Meeting notes
				m = {
					description = "Meeting",
					template = "* MEETING with %^{Meeting with} :meeting:\n%u\n** Attendees\n- %?\n\n** Agenda\n\n** Notes\n\n** Action Items\n",
					target = "~/.orgfiles/gtd/inbox.org",
					headline = "Meetings",
				},
			},

			-- GTD workflow states
			org_todo_keywords = {
				"TODO(t)",
				"NEXT(n)",
				"WAITING(w)",
				"SOMEDAY(s)",
				"|",
				"DONE(d)",
				"CANCELLED(c)",
			},

			-- Track completion time
			org_log_done = "time",
			org_log_into_drawer = "LOGBOOK",

			-- Tags configuration
			org_tags_exclude_from_inheritance = { "project" },
			org_use_tag_inheritance = true,

			-- Default priorities
			org_priority_highest = "A",
			org_priority_default = "C",
			org_priority_lowest = "E",

			-- Key mappings
			mappings = {
				global = {
					org_agenda = "<Leader>oa",
					org_capture = "<Leader>oc",
					org_jump = "<Leader>oj", -- Jump to bookmarked location
					org_clock_goto = "<Leader>ox", -- Go to currently clocked item
				},
				org = {
					org_refile = "R",
					org_todo = "t",
					org_toggle_checkbox = "<C-Space>",
					org_priority_up = "]p",
					org_priority_down = "[p",
					org_timestamp_up = "]d",
					org_timestamp_down = "[d",
					org_clock_in = "I",
					org_clock_out = "O",
					org_clock_cancel = "X",
					org_open_at_point = "<CR>",
					org_cycle = "<Tab>",
					org_global_cycle = "<S-Tab>",
					org_archive_subtree = "A",
					org_set_tags_command = "<Leader>ot", -- codespell:ignore ot
					org_toggle_archive_tag = "<Leader>oA",
					org_do_promote = "<<",
					org_do_demote = ">>",
				},
				capture = {
					org_capture_finalize = "<Leader>ow",
					org_capture_refile = "<Leader>or",
					org_capture_kill = "<Leader>ok",
				},
				agenda = {
					org_agenda_later = "L",
					org_agenda_earlier = "H",
					org_agenda_goto = "<CR>",
					org_agenda_day_view = "vd",
					org_agenda_week_view = "vw",
					org_agenda_month_view = "vm",
					org_agenda_year_view = "vy",
					org_agenda_quit = "q",
				},
			},

			-- Notifications for scheduled items
			notifications = {
				enabled = true,
				repeater_reminder_time = 10, -- In minutes
				deadline_warning_reminder_time = 10, -- In minutes
			},

			-- Agenda view customization
			org_agenda_span = "day",
			org_agenda_start_on_weekday = 1, -- Start on Monday

			-- Custom agenda views
			org_agenda_templates = {
				d = {
					description = "Daily Agenda",
					agenda_filter = "+SCHEDULED=<today>|+DEADLINE=<today>",
				},
				n = {
					description = "Next Actions",
					todo_filter = { "NEXT" },
				},
				w = {
					description = "Waiting",
					todo_filter = { "WAITING" },
				},
				f = {
					description = "File Tasks",
					tags_filter = "+file",
				},
				c = {
					description = "Code Tasks",
					tags_filter = "+code",
				},
				b = {
					description = "Bugs",
					tags_filter = "+bug",
				},
				k = {
					description = "Knowledge Notes",
					tags_filter = "+knowledge",
				},
				j = {
					description = "Journal Entries",
					tags_filter = "+journal",
				},
			},
		})
	end,
}
