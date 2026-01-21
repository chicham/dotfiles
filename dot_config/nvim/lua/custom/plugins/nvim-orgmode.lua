-- Orgmode Configuration
-- See full documentation at: https://github.com/nvim-orgmode/orgmode/blob/master/README.org

return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"ibhagwan/fzf-lua", -- Ensure fzf-lua loads for UI selection
	},
	config = function()
		local utils = require('orgmode.utils')
		local fs = require('orgmode.utils.fs')
		
		-- Experiment title/slug helpers for filename
		_G.prompt_experiment_title = function()
			if not _G._experiment_title then
				local title = vim.fn.input("Experiment Title: ")
				_G._experiment_title = title ~= "" and title or "untitled"
				_G._experiment_slug = _G._experiment_title:gsub("%s+", "-"):gsub("[^%w%-]", ""):lower()
			end
			return _G._experiment_title
		end

		_G.get_experiment_slug = function()
			if not _G._experiment_slug then _G.prompt_experiment_title() end
			return _G._experiment_slug
		end

		-- Define experiment template generator (single source of truth)
		-- This function is called by both capture template and promotion function
		_G.get_experiment_template_sections = function()
			-- Clear experiment title globals after template use
			vim.schedule(function()
				_G._experiment_title = nil
				_G._experiment_slug = nil
			end)
			return [[** Question/Purpose


** Hypothesis
# What do you think the results will be based on your research?

** Background Research
# What have you learned from books, papers, articles about this topic?
# Keep track of sources for your bibliography

** Materials
# List everything needed: equipment, tools, quantities
# Be very specific with details

** Variables
# - Controlled variables (what stays the same):
# - Manipulated variable (what you change):
# - Responding variable (what you measure):

** Procedure
# Step-by-step instructions to repeat your experiment
# If you make changes, document them here with reasons

** Log
*** ]] .. os.date("%Y-%m-%d %a") .. [[

- Notes:

** Data/Observations
# Record all measurements and raw data
# Use tables, charts, pictures

** Results
# Analyze your data
# What patterns do you see?
# Any problems during testing?

** Conclusions
# Was your hypothesis correct? Why or why not?
# What did you learn?

** Next Steps/Applications
# Recommendations for improving the experiment
# Ideas for further study
# Real-world applications
]]
		end
		
		local org_dirs = {
			gtd = "~/.orgfiles/gtd",
			gtd_projects = "~/.orgfiles/gtd/projects",
			research = "~/.orgfiles/research",
			roam = "~/.orgfiles/roam",
			roam_notes = "~/.orgfiles/roam/notes",
			roam_daily = "~/.orgfiles/roam/daily",
			experiments = "~/.orgfiles/experiments",
		}

		local org_files = {
			gtd_inbox = org_dirs.gtd .. "/inbox.org",
			gtd_someday = org_dirs.gtd .. "/someday.org",
			gtd_tickler = org_dirs.gtd .. "/tickler.org",
			gtd_archive = org_dirs.gtd .. "/archive.org",
		}

		for _, dir in ipairs({
			org_dirs.gtd,
			org_dirs.gtd_projects,
			org_dirs.research,
			org_dirs.roam,
			org_dirs.roam_notes,
			org_dirs.roam_daily,
			org_dirs.experiments,
		}) do
			vim.fn.mkdir(vim.fn.expand(dir), "p")
		end

		local function ensure_headlines(path, headlines)
			local lines = {}
			if vim.fn.filereadable(path) == 1 then
				local ok, result = pcall(function()
					return utils.readfile(path):wait()
				end)
				if ok and type(result) == 'table' then
					lines = result
				end
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
				vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
				utils.writefile(path, table.concat(lines, '\n')):wait()
			end
		end

		local function ensure_inbox_headlines()
			ensure_headlines(org_files.gtd_inbox, { "Tasks", "Notes", "Reading List", "Misc" })
		end

		_G.org_capture_git_root = function()
			if utils.current_file_path() == '' then
				return ''
			end
			local dir = fs.get_current_file_dir()
			local result = vim.fn.systemlist({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })
			if vim.v.shell_error ~= 0 or not result[1] or result[1] == '' then
				return ''
			end
			return vim.trim(result[1])
		end

		_G.org_capture_display_path = function()
			local path = utils.current_file_path()
			if path == '' then
				return 'capture'
			end
			path = vim.fn.fnamemodify(path, ':p')
			local root = _G.org_capture_git_root()
			if root ~= '' then
				root = vim.fn.fnamemodify(root, ':p')
				if vim.startswith(path, root .. '/') then
					return path:sub(#root + 2)
				end
			end
			local rel = vim.fn.fnamemodify(path, ':.')
			if rel ~= '' and rel ~= path then
				return rel
			end
			return vim.fn.fnamemodify(path, ':t')
		end

		_G.org_capture_default_title = function()
			local path = utils.current_file_path()
			if path == '' then
				return 'capture'
			end
			local line_nr = vim.api.nvim_win_get_cursor(0)[1]
			return _G.org_capture_display_path() .. ':' .. line_nr
		end

		_G.org_capture_git_commit = function()
			if utils.current_file_path() == '' then
				return 'N/A'
			end
			local dir = fs.get_current_file_dir()
			local result = vim.fn.systemlist({ 'git', '-C', dir, 'rev-parse', 'HEAD' })
			if vim.v.shell_error ~= 0 or not result[1] or result[1] == '' then
				return 'N/A'
			end
			return vim.trim(result[1])
		end

		_G.org_capture_file_path = function()
			local path = utils.current_file_path()
			if path == '' then
				return 'N/A'
			end
			return vim.fn.fnamemodify(path, ':p')
		end

		_G.org_capture_abs_link = function()
			local path = utils.current_file_path()
			if path == '' then
				return ''
			end
			path = vim.fn.fnamemodify(path, ':p')
			local line_nr = vim.api.nvim_win_get_cursor(0)[1]
			local display = _G.org_capture_default_title()
			return string.format('[[file:%s::%d][%s]]', path, line_nr, display)
		end

		_G.org_capture_line_text = function()
			local line = vim.api.nvim_get_current_line()
			local max_len = 200
			if #line > max_len then
				line = line:sub(1, max_len - 3) .. '...'
			end
			return line
		end

		local function org_experiment_log_today()
			local bufnr = vim.api.nvim_get_current_buf()
			local path = vim.api.nvim_buf_get_name(bufnr)
			if path == '' then
				vim.notify('No file path for current buffer.', vim.log.levels.WARN)
				return
			end

			local experiments_root = vim.fn.fnamemodify(vim.fn.expand(org_dirs.experiments), ':p')
			local file_path = vim.fn.fnamemodify(path, ':p')
			if not vim.startswith(file_path, experiments_root .. '/') then
				vim.notify('Not in an experiments file.', vim.log.levels.WARN)
				return
			end

			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local log_line = nil
			local log_level = nil
			for i, line in ipairs(lines) do
				local stars, title = line:match('^(%*+)%s+(.+)$')
				if stars and title == 'Log' then
					log_line = i
					log_level = #stars
					break
				end
			end

			local day_title = os.date('%Y-%m-%d %a')
			local day_level = (log_level or 2) + 1
			local day_heading = string.rep('*', day_level) .. ' ' .. day_title

			if log_line then
				local insert_at = #lines
				for i = log_line + 1, #lines do
					local stars, title = lines[i]:match('^(%*+)%s+(.+)$')
					if stars then
						if #stars <= log_level then
							insert_at = i - 1
							break
						end
						if #stars == log_level + 1 and title == day_title then
							vim.api.nvim_win_set_cursor(0, { i, 0 })
							return
						end
					end
				end

				vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, { day_heading, '' })
				vim.api.nvim_win_set_cursor(0, { insert_at + 1, 0 })
				return
			end

			local insert_lines = {}
			if #lines > 0 and lines[#lines] ~= '' then
				table.insert(insert_lines, '')
			end
			table.insert(insert_lines, '** Log')
			table.insert(insert_lines, day_heading)
			table.insert(insert_lines, '')
			vim.api.nvim_buf_set_lines(bufnr, #lines, #lines, false, insert_lines)
			vim.api.nvim_win_set_cursor(0, { #lines + #insert_lines - 1, 0 })
		end

		ensure_inbox_headlines()
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
		--    - Tasks live in the inbox and are scheduled there.
		--    - Open Today's Daily Log for notes and completed work.
		--    - Use Clock In (I) and Clock Out (O) to track advising vs. coding time.
		--    - Use <Leader>oa to see the consolidated Agenda across all files.
		-- =============================================================================

		-- Define agenda files in a variable so we can reuse them for refile targets
		local agenda_globs = {
			org_files.gtd_inbox,
			org_dirs.gtd_projects .. "/**/*.org",
			org_files.gtd_someday,
			org_files.gtd_tickler,
			org_dirs.research .. "/*.org",
			org_dirs.roam .. "/**/*.org",
			org_dirs.experiments .. "/**/*.org",
		}

		-- Setup orgmode with GTD-focused research workflow
		require("orgmode").setup({
			-- File organization for GTD + research workflow
			org_agenda_files = agenda_globs,
			org_default_notes_file = org_files.gtd_inbox,
			org_agenda_custom_commands = {
				r = {
					description = "Running experiments",
					types = {
						{
							type = "tags_todo",
							match = "experiment/WORKING",
							org_agenda_overriding_header = "Running Experiments",
						},
					},
				},
			},

			-- Archive configuration
			-- Move archived items to a central archive file under a headline matching the source file name
			org_archive_location = vim.fn.expand(org_files.gtd_archive) .. "::* From %s",

			-- Refile settings
			-- Build a flat list of all headlines (Level 1-3) across all agenda files.
			org_refile_targets = {
				{ agenda_globs, maxlevel = 3 },
			},
			org_refile_use_outline_path = false,

			-- Rationalized capture templates (core workflows only)
			org_capture_templates = {
				-- Inbox task (adds file link when available)
				t = {
					description = "Task (Inbox)",
					template = "* TODO %?\n:PROPERTIES:\n:ID: %(return require('orgmode.org.id').new())\n:CREATED: %U\n:END:\n%a",
					target = org_files.gtd_inbox,
					headline = "Tasks",
				},
				n = {
					description = "Note",
					template = [[:PROPERTIES:
:ID: %(return require('orgmode.org.id').new())
:CREATED: %U
:END:
#+TITLE: %^{Title}
#+FILETAGS: :note:

* Notes
%?]],
					target = org_dirs.roam_notes .. "/note-%<%Y%m%d%H%M%S>.org",
					whole_file = true,
				},
				m = {
					description = "Meeting",
					template = [[:PROPERTIES:
:ID: %(return require('orgmode.org.id').new())
:CREATED: %U
:END:
#+TITLE: %^{Meeting Title}
#+FILETAGS: :meeting:
#+DATE: %<%Y-%m-%d %a>

* Attendees
- %^{Attendees}

* Agenda
- %?

* Notes

* Action Items
- [ ]
]],
					target = org_dirs.roam_notes .. "/meeting-%<%Y%m%d%H%M%S>.org",
					whole_file = true,
				},

				e = {
					description = "Experiment",
					template = [[
* %^{Status|TODO|WORKING|WAITING|DONE|CANCELLED} %(return _G.prompt_experiment_title()) :experiment:
:PROPERTIES:
:ID: %(return require('orgmode.org.id').new())
:CREATED: %U
:END:

%(return _G.get_experiment_template_sections())%?]],
					target = org_dirs.experiments .. "/%<%Y-%m-%d>-%(return _G.get_experiment_slug()).org",
				},

				-- Reading (Quick Capture to Inbox: Blogs, Papers, etc.)
				r = {
					description = "Reading",
					template = "* TODO %^{Title} :reading:\n:PROPERTIES:\n:ID: %(return require('orgmode.org.id').new())\n:CREATED: %U\n:END:\n- Link: [[%^{URL}]]",
					target = org_files.gtd_inbox,
					headline = "Reading List",
				},

				l = {
					description = "Link (Commit)",
					template = "* %^{Title|%(return _G.org_capture_default_title())}\n:PROPERTIES:\n:ID: %(return require('orgmode.org.id').new())\n:CREATED: %U\n:FILE: %(return _G.org_capture_file_path())\n:COMMIT: %(return _G.org_capture_git_commit())\n:END:\n- Source: %(return _G.org_capture_abs_link())\n- Line: %(return _G.org_capture_line_text())",
					target = org_files.gtd_inbox,
					headline = "Misc",
				},

				-- Quick note to today's daily log
				o = {
					description = "Quick note (Today)",
					template = "** %?\n:PROPERTIES:\n:ID: %(return require('orgmode.org.id').new())\n:CREATED: %U\n:END:",
					target = org_dirs.roam_daily .. "/%<%Y-%m-%d>.org",
					headline = "Notes",
				},
			},

			-- GTD workflow states
			org_todo_keywords = {
				"TODO(t)",
				"WORKING(w)",
				"NEXT(n)",
				"WAITING(p)",
				"SOMEDAY(s)",
				"|",
				"DONE(d)",
				"CANCELLED(c)",
			},
			org_todo_keyword_faces = {
				WORKING = "foreground #FFA500",
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

			-- User interface configuration (fzf-lua first, fallback to vim.ui.select)
			ui = {
				menu = {
					handler = function(data)
						local options = {}
						local options_by_label = {}

						for _, item in ipairs(data.items) do
							if item.key and item.label:lower() ~= "quit" then
								local display = string.format("[%s] %s", item.key, item.label)
								table.insert(options, display)
								options_by_label[display] = item
							end
						end

						local function select_item(choice)
							if not choice then
								return
							end
							local option = options_by_label[choice]
							if option and option.action then
								option.action()
							end
						end

						local ok, fzf = pcall(require, "fzf-lua")
						if ok then
							fzf.fzf_exec(options, {
								prompt = data.title .. " > ",
								actions = {
									["default"] = function(selected)
										if selected and selected[1] then
											select_item(selected[1])
										end
									end,
								},
								winopts = {
									height = 0.6,
									width = 0.8,
								},
							})
						else
							vim.ui.select(options, { prompt = data.title .. " > " }, select_item)
						end
					end,
				},
			},

			-- Key mappings
			mappings = {
				global = {
					org_agenda = "<Leader>oa",
					org_capture = "<Leader>oc",
					org_jump = "<Leader>oj", -- Jump to bookmarked location
					org_clock_goto = "<Leader>ox", -- Go to currently clocked item
				},
				org = {
					org_refile = "<Leader>oR", -- Native refile as fallback (R = fzf refile)
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
		vim.keymap.set("n", "<Leader>op", function()
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
			local path = vim.fn.expand(org_dirs.gtd_projects .. "/" .. slug .. ".org")

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
		end, { desc = "Create new [P]roject file" })

		-- Refile helper (fzf-lua first, fallback to vim.ui.select)
		_G.org_refile_with_fzf = function(opts)
			opts = opts or {}
			local org = require("orgmode").instance()
			local files = org.files
			local capture = org.capture

			local source_file = opts.source_file or files:get_current_file()
			local source_headline = opts.source_headline or (source_file and source_file:get_closest_headline())
			if not source_headline then
				vim.notify("No headline found under cursor.", vim.log.levels.WARN)
				return
			end

			local source_bufnr = opts.source_bufnr or (source_file and source_file:bufnr())

			if opts.ensure_path then
				files:get(opts.ensure_path)
			end

			local valid_destinations = capture:_get_autocompletion_files()

			-- Build items list with direct mapping
			local items = {}
			local item_map = {}

			-- Find the only_key if destination_path is specified
			local only_key = opts.only_key
			if opts.destination_path then
				local target_path = vim.fn.fnamemodify(opts.destination_path, ':p')
				for key, file in pairs(valid_destinations) do
					local file_path = vim.fn.fnamemodify(file.filename, ':p')
					if file_path == target_path then
						only_key = key
						break
					end
				end
			end

			local keys = vim.tbl_keys(valid_destinations)
			table.sort(keys)

			for _, key in ipairs(keys) do
				if not only_key or only_key == key then
					if opts.include_file ~= false then
						table.insert(items, key)
						item_map[key] = { file = valid_destinations[key] }
					end

					local file = valid_destinations[key]
					for _, headline in ipairs(file:get_opened_unfinished_headlines()) do
						local title = headline:get_title()
						if title and title ~= "" then
							local display = key .. title
							table.insert(items, display)
							item_map[display] = { file = file, headline = headline }
						end
					end
				end
			end

			-- Prioritize default headline if specified
			if opts.default_headline and only_key then
				local target = only_key .. opts.default_headline
				for idx, value in ipairs(items) do
					if value == target then
						table.remove(items, idx)
						table.insert(items, 1, value)
						break
					end
				end
			end

			if #items == 0 then
				vim.notify("No refile targets found.", vim.log.levels.WARN)
				return
			end

			local function select_item(choice)
				if not choice then
					return
				end

				local dest = item_map[choice]
				if not dest then
					vim.notify("Invalid destination.", vim.log.levels.ERROR)
					return
				end

				local prev_bufnr = vim.api.nvim_get_current_buf()
				if source_bufnr and vim.api.nvim_buf_is_valid(source_bufnr) then
					vim.api.nvim_set_current_buf(source_bufnr)
				end

				capture:_refile_from_org_file({
					source_headline = source_headline,
					destination_file = dest.file,
					destination_headline = dest.headline,
					message = opts.message,
				})

				if prev_bufnr and vim.api.nvim_buf_is_valid(prev_bufnr) then
					vim.api.nvim_set_current_buf(prev_bufnr)
				end
			end

			local ok, fzf = pcall(require, "fzf-lua")
			if ok then
				fzf.fzf_exec(items, {
					prompt = opts.prompt or "Refile to > ",
					actions = {
						["default"] = function(selected)
							if selected and selected[1] then
								select_item(selected[1])
							end
						end,
					},
					winopts = {
						height = 0.6,
						width = 0.8,
					},
				})
			else
				vim.ui.select(items, { prompt = opts.prompt or "Refile to > " }, select_item)
			end
		end

		-- Insert stored links via fzf-lua (fallback to vim.ui.select)
		_G.org_insert_link_fzf = function()
			local org = require("orgmode")
			local links = org.links
			local stored = links and links.stored_links or {}

			if type(stored) ~= "table" or vim.tbl_isempty(stored) then
				return org.org_mappings:insert_link()
			end

			local items = {}
			local item_map = {}
			local manual_label = "[manual] Enter link"

			item_map[manual_label] = { manual = true }
			table.insert(items, manual_label)

			for link, title in pairs(stored) do
				local display = string.format("%s :: %s", title, link)
				table.insert(items, display)
				item_map[display] = { link = link, title = title }
			end

			table.sort(items, function(a, b)
				if a == manual_label then
					return true
				end
				if b == manual_label then
					return false
				end
				return a < b
			end)

			local function select_item(choice)
				if not choice then
					return
				end
				local item = item_map[choice]
				if not item then
					return
				end
				if item.manual then
					return org.org_mappings:insert_link()
				end
				return links:insert_link(item.link, item.title)
			end

			local ok, fzf = pcall(require, "fzf-lua")
			if ok then
				fzf.fzf_exec(items, {
					prompt = "Links> ",
					actions = {
						["default"] = function(selected)
							if selected and selected[1] then
								select_item(selected[1])
							end
						end,
					},
					winopts = {
						height = 0.6,
						width = 0.8,
					},
				})
			else
				vim.ui.select(items, { prompt = "Links> " }, select_item)
			end
		end

		local function org_todo_next_state_with_working()
			local org = require("orgmode")
			local files = org.instance().files
			local headline = files:get_closest_headline()

			if not headline then
				vim.notify("No headline found under cursor.", vim.log.levels.WARN)
				return
			end

			local old_state = headline:get_todo()
			org.action("org_mappings.todo_next_state")

			local updated = files:get_closest_headline()
			if not updated then
				return
			end

			local new_state = updated:get_todo()
			if new_state == "WORKING" then
				org.action("clock.org_clock_in")
			elseif old_state == "WORKING" and new_state ~= "WORKING" then
				org.action("clock.org_clock_out")
			end
		end

		vim.api.nvim_create_autocmd('FileType', {
			pattern = 'org',
			callback = function()
				vim.schedule(function()
					vim.keymap.set('n', 'R', function()
						_G.org_refile_with_fzf()
					end, { buffer = true, desc = 'Refile with Fzf' })
					vim.keymap.set('n', 't', function()
						org_todo_next_state_with_working()
					end, { buffer = true, desc = 'TODO next state (clock WORKING)' })
					vim.keymap.set({ 'n', 'v' }, '<Leader>oli', function()
						_G.org_insert_link_fzf()
					end, { buffer = true, desc = 'Insert link (fzf)' })
				end)
			end,
		})
	end,
}
