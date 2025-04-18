git return {
	"nvim-orgmode/orgmode",
	ft = { "org" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		-- Explicitly load the org parser first

		-- Setup orgmode with GTD-focused research workflow
		require("orgmode").setup({
			-- File organization for GTD + research workflow
			org_agenda_files = {
				"~/.orgfiles/gtd/inbox.org",
				"~/.orgfiles/gtd/projects.org",
				"~/.orgfiles/gtd/someday.org",
				"~/.orgfiles/gtd/tickler.org",
				"~/.orgfiles/research/*.org",
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
			},

			-- GTD workflow states
			org_todo_keywords = {
				"TODO(t)",
				"NEXT(n)",
				"WAITING(w)",
				"SOMEDAY(s)",
				"|",
				"DONE(d)",
				"CANCELLED(c)"
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
				},
				org = {
					org_refile = "R",
					org_todo = "t",
					org_toggle_checkbox = "<C-Space>",
					org_priority_up = "]p",
					org_priority_down = "[p",
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
			},
		})
	end,
}
