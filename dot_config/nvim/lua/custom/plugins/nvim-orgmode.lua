-- Orgmode Configuration
-- See full documentation at: https://github.com/nvim-orgmode/orgmode/blob/master/README.org

return {
	"nvim-orgmode/orgmode",
	lazy = false,
	ft = { "org" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"ibhagwan/fzf-lua", -- Ensure fzf-lua loads for UI selection
	},
	config = function()
		local function ensure_daily_headlines(path, headlines)
			local lines = {}
			local exists = vim.fn.filereadable(path) == 1

			if exists then
				lines = vim.fn.readfile(path)
			end

			local existing = {}
			for _, line in ipairs(lines) do
				local headline = line:match("^%*+%s+(.+)$")
				if headline then
					existing[headline] = true
				end
			end

			local updated = false
			for _, headline in ipairs(headlines) do
				if not existing[headline] then
					if lines[#lines] ~= "" then
						table.insert(lines, "")
					end
					table.insert(lines, "* " .. headline)
					table.insert(lines, "")
					updated = true
				end
			end

			if updated and #lines > 0 then
				vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
				vim.fn.writefile(lines, path)
			end
		end

		_G.ensure_daily_capture_targets = function()
			local date = os.date("%Y-%m-%d")
			local path = vim.fn.expand("~/.orgfiles/roam/daily/" .. date .. ".org")
			if _G.org_roam_ensure_daily_file then
				path = _G.org_roam_ensure_daily_file()
			end
			if path then
				ensure_daily_headlines(path, { "Planned", "Done", "Notes" })
			end
			return path
		end

		_G.org_daily_notes_heading = function()
			local date = os.date("%Y-%m-%d")
			local path = vim.fn.expand("~/.orgfiles/roam/daily/" .. date .. ".org")
			_G.ensure_daily_capture_targets()
			local org = require("orgmode")
			local file = org.instance().files:get(path)

			if file then
				for _, headline in ipairs(file:get_headlines()) do
					if headline:get_title() == "Notes" then
						return string.rep("*", headline:get_level() + 1) .. " "
					end
				end
			end

			return "** "
		end
		-- =============================================================================
		-- HIGH-PERFORMANCE WORKFLOW DOCUMENTATION
		-- =============================================================================
		-- 1. CAPTURE (Anytime):
		--    Use <Leader>oc to quickly dump ideas, tasks, or papers into the INBOX.
		--    Don't think about organization yet; just get it out of your head.
		--
		-- 2. CLARIFY (Morning/Evening):
		--    Open ~/.orgfiles/gtd/inbox.org.
		--    For each item, decide its fate:
		--    - Do it now (if < 2 mins).
		--    - Refile (R) to a Project file (~/.orgfiles/gtd/projects.org).
		--    - Refile (R) to Today's Daily Log if it's an execution priority.
		--    - Move to Someday/Maybe (s) if not actionable yet.
		--
		-- 3. EXECUTE (During Work):
		--    - Open Today's Daily Log (<Leader>nd) to see your "Planned" battle plan.
		--    - Use Clock In (I) and Clock Out (O) to track advising vs. coding time.
		--    - Use <Leader>oa to see the consolidated Agenda across all files.
		-- =============================================================================

		-- Define agenda files in a variable so we can reuse them for refile targets
		local agenda_globs = {
			"~/.orgfiles/gtd/inbox.org",
			"~/.orgfiles/gtd/projects/**/*.org",
			"~/.orgfiles/gtd/someday.org",
			"~/.orgfiles/gtd/tickler.org",
			"~/.orgfiles/research/*.org",
			"~/.orgfiles/roam/**/*.org",
		}

		-- Setup orgmode with GTD-focused research workflow
		require("orgmode").setup({
			-- File organization for GTD + research workflow
			org_agenda_files = agenda_globs,
			org_default_notes_file = "~/.orgfiles/gtd/inbox.org",

			-- Archive configuration
			-- Move archived items to a central archive file under a headline matching the source file name
			org_archive_location = vim.fn.expand("~/.orgfiles/gtd/archive.org") .. "::* From %s",

			-- Refile settings
			-- Build a flat list of all headlines (Level 1-3) across all agenda files.
			org_refile_targets = {
				{ agenda_globs, maxlevel = 3 },
			},
			org_refile_use_outline_path = false,

			-- Enhanced capture templates for GTD with file focus
			org_capture_templates = {
				-- Quick file task (primary use case requested)
				f = {
					description = "File Task",
					template = "* TODO %? :file:\n%u\n%a", -- %a adds a link to the current file position
					target = "~/.orgfiles/gtd/inbox.org",
					headline = "Tasks",
				},

				-- Other GTD workflow captures
				i = {
					description = "Inbox",
					template = "* TODO %?\n%u",
					target = "~/.orgfiles/gtd/inbox.org",
				},
				n = {
					description = "Note",
					template = "* %^{Title} :note:\n:PROPERTIES:\n:ID: %(return require('orgmode.org.id').new())\n:CREATED: %U\n:END:\n\n%?",
					target = "~/.orgfiles/gtd/inbox.org",
					headline = "Notes",
				},

				e = {
					description = "Experiment Log",
					template = "* %^{Experiment Title} :experiment:\n:PROPERTIES:\n:ID: %(return require('orgmode.org.id').new())\n:CREATED: %U\n:PROJECT: %^{Project}\n:DATASET: %^{Dataset}\n:MODEL: %^{Model}\n:METRICS: %^{Metrics}\n:ASSETS: %^{Assets}\n:END:\n\n** Goal\n%?\n\n** Hypothesis\n\n** Method\n\n** Results\n\n** Notes\n\n** Next Steps\n",
					target = "~/.orgfiles/gtd/inbox.org",
					headline = "Experiments",
				},

				h = {
					description = "Idea Backlog",
					template = "* %^{Idea} :idea:\n:PROPERTIES:\n:ID: %(return require('orgmode.org.id').new())\n:CREATED: %U\n:END:\n\n%?",
					target = "~/.orgfiles/gtd/inbox.org",
					headline = "Notes",
				},

				-- Daily note captures (integrated with org-roam dailies)
				j = {
					description = "Daily Planned Task",
					template = "* TODO %?",
					target = "~/.orgfiles/roam/daily/%<%Y-%m-%d>.org",
					headline = "Planned",
				},

				d = {
					description = "Daily Done (Completed)",
					template = "  - [X] %? :CLOSED: %U",
					target = "~/.orgfiles/roam/daily/%<%Y-%m-%d>.org",
					headline = "Done",
				},

				o = {
					description = "Daily Note",
					template = "%(return _G.org_daily_notes_heading())%?",
					target = "~/.orgfiles/roam/daily/%<%Y-%m-%d>.org",
					headline = "Notes",
				},

				-- Reading (Quick Capture to Inbox: Blogs, Papers, etc.)
				r = {
					description = "Reading",
					template = "* TODO %^{Title} :reading:\n- Link: [[%^{URL}]]\n%u",
					target = "~/.orgfiles/gtd/inbox.org",
					headline = "Reading List",
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
					org_refile = false, -- Disable default to use our custom Fzf wrapper
					org_todo = "t",
					org_toggle_checkbox = "<Leader>x",
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
					org_archive_subtree = "<Leader>os", -- Archive Subtree under Leader-o
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
		})

		-- Custom Command to Create a New Project File
		vim.keymap.set("n", "<Leader>on", function()
			local name = vim.fn.input("Project Name: ")
			if name == "" then
				return
			end

			local tags_input = vim.fn.input("Project Tags (space separated): ")
			local tags = ":project:"
			if tags_input ~= "" then
				-- Clean up input: replace spaces with colons, remove non-alphanumeric (except -_@), ensure wrapped in colons
				local clean_tags = tags_input:gsub("%s+", ":"):gsub("[^%w%-%_@:]", "")
				if clean_tags ~= "" then
					if not clean_tags:match("^:") then clean_tags = ":" .. clean_tags end
					if not clean_tags:match(":$") then clean_tags = clean_tags .. ":" end
					tags = tags .. clean_tags:sub(2) -- Avoid double colon
				end
			end

			-- Sanitize filename
			local slug = name:gsub("%s+", "-"):gsub("[^%w%-]", ""):lower()
			local path = vim.fn.expand("~/.orgfiles/gtd/projects/" .. slug .. ".org")

			-- Check if file exists to avoid overwriting
			if vim.fn.filereadable(path) == 1 then
				print("Project file already exists: " .. path)
				vim.cmd("edit " .. path)
				return
			end

			-- Create file content
			local content = {
				"#+TITLE: " .. name,
				"#+FILETAGS: " .. tags,
				"#+CATEGORY: " .. name,
				"",
				"* Description",
				"",
				"* Tasks",
				"",
				"* Notes",
				"",
			}

			-- Write file
			local file = io.open(path, "w")
			if file then
				for _, line in ipairs(content) do
					file:write(line .. "\n")
				end
				file:close()
				print("Created new project: " .. path)
				vim.cmd("edit " .. path)
			else
				print("Error creating file: " .. path)
			end
		end, { desc = "Create [N]ew Project File" })

		-- Custom Refile using Fzf-lua
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "org",
			callback = function()
				vim.keymap.set("n", "R", function()
					local fzf = require("fzf-lua")
					local org = require("orgmode")
					local files = org.instance().files
					local capture = org.instance().capture

					-- Capture source headline before opening fzf so we keep the right buffer context.
					local source_file = files:get_current_file()
					local source_headline = source_file and source_file:get_closest_headline()
					if not source_headline then
						print("No headline found under cursor.")
						return
					end
					local source_bufnr = source_file:bufnr()
					
					-- Search for headlines in agenda files
					fzf.grep({
						search = "^\\*+\\s", -- Regex for headlines
						cwd = "~/.orgfiles",
						prompt = "Refile Target> ",
						no_esc = true,
						file_icons = false, -- Disable icons to ensure clean filename parsing
						git_icons = false,
						actions = {
							["default"] = function(selected)
								if not selected or #selected == 0 then return end
								-- Parse selection: filename:line:column:content
								-- Since we disabled icons, this standard format should work reliable
								local entry = selected[1]
								local filename, line, col, text = entry:match("^([^:]+):(%d+):(%d+):(.*)$")
								
								if not filename or not line then
									print("Invalid selection format: " .. (entry or "nil"))
									return
								end
								
								-- Ensure filename is absolute or correct relative to CWD
								-- fzf-lua usually returns relative paths from cwd (~/.orgfiles)
								-- We need to prepend the cwd if it's relative
								local full_path = filename
								if not full_path:match("^/") and not full_path:match("^~") then
									full_path = vim.fn.expand("~/.orgfiles/") .. filename
								end

								-- Destination
								local dest_file = files:get(full_path)
								
								if not dest_file then
									print("Could not find destination file: " .. full_path)
									return
								end
								
								local dest_headline = dest_file:get_closest_headline({ tonumber(line), 0 })
								
								-- If no headline found at that line, we might be targeted the file itself or a top-level context.
								-- _refile_from_org_file handles nil destination_headline by appending to end of file (or top level).
								-- However, since we are selecting a specific line in Fzf, it's usually a headline.
								-- If get_closest_headline returns nil, it means we are before the first headline.
								
								-- Perform Refile using internal API
								-- This function handles all the logic: moving text, adjusting levels, saving files.
								local prev_bufnr = vim.api.nvim_get_current_buf()
								if source_bufnr and vim.api.nvim_buf_is_valid(source_bufnr) then
									vim.api.nvim_set_current_buf(source_bufnr)
								end
								capture:_refile_from_org_file({
									source_headline = source_headline,
									destination_file = dest_file,
									destination_headline = dest_headline
								})
								if prev_bufnr and vim.api.nvim_buf_is_valid(prev_bufnr) then
									vim.api.nvim_set_current_buf(prev_bufnr)
								end
							end
						}
					})
				end, { buffer = true, desc = "Refile with Fzf" })
			end,
		})
	end,
}
