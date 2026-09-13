-- Orgmode Configuration
-- See full documentation at: https://github.com/nvim-orgmode/orgmode/blob/master/README.org

return {
  "nvim-orgmode/orgmode",
  -- Nothing outside an org file needs orgmode loaded, and setup() is not
  -- cheap: it creates seven directories and builds the agenda file list. The
  -- triggers below are the complete set of ways in -- an org buffer, the `:Org`
  -- command, or one of the global maps that setup() would otherwise have to be
  -- running to install. The `keys` entries carry no right-hand side on purpose:
  -- the first press loads the plugin and replays into the mapping setup() just
  -- created, so the binding stays owned by the `mappings.global` table below.
  --
  -- The blink source is part of this: `orgmode.org.autocompletion.blink`
  -- requires orgmode at module scope, so listing it in blink's `sources.default`
  -- would load orgmode from the first completion in any buffer. It is declared
  -- per-filetype instead (see blink-cmp.lua).
  ft = "org",
  cmd = "Org",
  keys = {
    { "<Leader>oa", desc = "Org agenda" },
    { "<Leader>oc", desc = "Org capture" },
    { "<Leader>oj", desc = "Org jump to bookmark" },
    { "<Leader>ox", desc = "Org goto clocked item" },
    { "<Leader>op", desc = "New org project file" },
  },
  dependencies = {
    "ibhagwan/fzf-lua", -- Ensure fzf-lua loads for UI selection
  },
  config = function()
    local orgfiles_base = vim.fn.expand("~/.orgfiles")
    local org_dirs = {
      gtd = orgfiles_base .. "/gtd",
      gtd_projects = orgfiles_base .. "/gtd/projects",
      research = orgfiles_base .. "/research",
      roam = orgfiles_base .. "/roam",
      roam_notes = orgfiles_base .. "/roam/notes",
      roam_daily = orgfiles_base .. "/roam/daily",
      experiments = orgfiles_base .. "/experiments",
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
      org_dirs.gtd .. "/reading.org",
      org_dirs.gtd_projects .. "/**/*.org",
      org_files.gtd_someday,
      org_files.gtd_tickler,
      org_dirs.research .. "/*.org",
      org_dirs.roam .. "/**/*.org",
      org_dirs.experiments .. "/**/*.org",
      orgfiles_base .. "/gcal.org",
    }

    -- Setup orgmode with GTD-focused research workflow
    require("orgmode").setup({
      -- File organization for GTD + research workflow
      org_agenda_files = agenda_globs,
      org_default_notes_file = org_files.gtd_inbox,

      -- Enable automatic indentation for proper folding
      org_startup_indented = true,
      org_adapt_indentation = true,

      -- Work day time grid: 9:30 - 18:30
      org_agenda_time_grid = {
        type = { "daily", "today", "require-timed" },
        times = { 930, 1030, 1130, 1230, 1330, 1430, 1530, 1630, 1730, 1830 },
      },

      org_agenda_custom_commands = {
        r = {
          description = "Running experiments",
          types = {
            {
              type = "tags_todo",
              match = "experiment/WORKING",
              org_agenda_overriding_header = "Running Experiments",
            },
            {
              type = "tags_todo",
              match = "experiment/WAITING",
              org_agenda_overriding_header = "Waiting Experiments",
            },
            {
              type = "tags_todo",
              match = "experiment/TODO",
              org_agenda_overriding_header = "Pending Experiments",
            },
          },
        },
        p = {
          description = "People — milestones & deadlines",
          types = {
            {
              type = "tags_todo",
              match = "person",
              org_agenda_overriding_header = "People — open items",
            },
          },
        },
        R = {
          description = "Reading queue (generative-retrieval)",
          types = {
            {
              type = "tags_todo",
              match = "reading/WORKING",
              org_agenda_overriding_header = "● Now reading (WORKING)",
            },
            {
              type = "tags_todo",
              match = "reading/NEXT",
              org_agenda_overriding_header = "○ Sprint — NEXT (READ_ORDER 01-08)",
            },
            {
              type = "tags_todo",
              match = "reading-park/TODO",
              org_agenda_overriding_header = "Backlog — TODO (by section; see :READ_ORDER:)",
            },
            {
              type = "tags_todo",
              match = "reading+park/TODO",
              org_agenda_overriding_header = "Parked — low GR-relevance (skip unless needed)",
            },
          },
        },
      },

      -- Archive configuration
      -- Move archived items to a central archive file under a headline matching the source file name
      org_archive_location = vim.fn.expand(org_files.gtd_archive) .. "::* From %s",

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
:PERSON: %(return require('custom.org').prompt_person_for_capture())
:END:
#+TITLE: %^{Meeting Title}
#+FILETAGS: :meeting:
#+DATE: %<%Y-%m-%d %a>

* Attendees
- %(return require('custom.org').capture.person_name or "")
- %?

* Agenda

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
* %^{Status|TODO|WORKING|WAITING|DONE|CANCELLED} %(return require('custom.org').prompt_experiment_title()) :experiment:
:PROPERTIES:
:ID: %(return require('orgmode.org.id').new())
:CREATED: %U
:END:

%(return require('custom.org').get_experiment_template_sections())%?]],
          target = org_dirs.experiments .. "/%<%Y-%m-%d>-%(return require('custom.org').get_experiment_slug()).org",
        },

        -- Reading (Quick Capture to Inbox: Blogs, Papers, etc.)
        r = {
          description = "Reading",
          template = "* TODO %^{Title} :reading:\n:PROPERTIES:\n:ID: %(return require('orgmode.org.id').new())\n:CREATED: %U\n:END:\n- Link: [[%^{URL}]]",
          target = org_files.gtd_inbox,
          headline = "Reading List",
        },

        l = {
          description = "Code TODO",
          template = "* TODO %^{Message}\n:PROPERTIES:\n:ID: %(return require('orgmode.org.id').new())\n:CREATED: %U\n:COMMIT: %(return require('custom.org').capture_git_commit())\n:END:\n%(return require('custom.org').capture_abs_link())",
          target = org_files.gtd_inbox,
          headline = "Tasks",
        },

        x = {
          description = "Experiment run (tracking)",
          template = [[
* WAITING %^{Run label}
SCHEDULED: <%<%Y-%m-%d %a>>
:PROPERTIES:
:ID: %(return require('orgmode.org.id').new())
:CREATED: %U
:RUN_ID: %^{artitrack run id (durable key)}
:TS_JOB: %^{ts_job train/eval}
:CELL: %^{Cell / config key}
:CORPUS: %^{Corpus}
:HARNESS: %^{Harness|xp_grid.py|xp_dsi.py}
:STEPS: %^{Step budget}
:END:
%?]],
          target = org_dirs.gtd_projects .. "/%(return require('custom.org').prompt_tracking_project())/tracking.org",
          headline = "Runs",
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
          -- No org_todo here: the FileType autocmd below binds `t` to a
          -- wrapper that also drives the clock, and it wins because it runs
          -- later. Leaving orgmode's default `cit` in place means the plain
          -- state change is still reachable when the wrapper is not wanted.
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
    --
    -- Nothing here runs inside a capture-template expansion, so the prompts go
    -- through `vim.ui.input` -- asynchronous, and routed to whatever input UI
    -- is configured -- rather than the blocking `vim.fn.input` the templates
    -- are stuck with.
    ---@param name string
    ---@param tags_input string
    local function create_project_file(name, tags_input)
      local tags = ":project:"
      if tags_input ~= "" then
        -- Clean up input: replace spaces with colons, remove non-alphanumeric (except -_@), ensure wrapped in colons
        local clean_tags = tags_input:gsub("%s+", ":"):gsub("[^%w%-%_@:]", "")
        if clean_tags ~= "" then
          if not clean_tags:match("^:") then
            clean_tags = ":" .. clean_tags
          end
          if not clean_tags:match(":$") then
            clean_tags = clean_tags .. ":"
          end
          tags = tags .. clean_tags:sub(2) -- Avoid double colon
        end
      end

      -- Sanitize filename
      local slug = name:gsub("%s+", "-"):gsub("[^%w%-]", ""):lower()
      local path = vim.fn.expand(org_dirs.gtd_projects .. "/" .. slug .. ".org")

      -- Check if file exists to avoid overwriting
      if vim.fn.filereadable(path) == 1 then
        vim.notify("Project file already exists: " .. path, vim.log.levels.WARN)
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        return
      end

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

      local file = io.open(path, "w")
      if not file then
        vim.notify("Error creating file: " .. path, vim.log.levels.ERROR)
        return
      end
      for _, line in ipairs(content) do
        file:write(line .. "\n")
      end
      file:close()
      vim.notify("Created new project: " .. path, vim.log.levels.INFO)
      vim.cmd("edit " .. vim.fn.fnameescape(path))
    end

    vim.keymap.set("n", "<Leader>op", function()
      vim.ui.input({ prompt = "Project Name: " }, function(name)
        if not name or name == "" then
          return
        end
        vim.ui.input({ prompt = "Project Tags (space separated): " }, function(tags_input)
          create_project_file(name, tags_input or "")
        end)
      end)
    end, { desc = "Create new [P]roject file" })

    -- Insert stored links via fzf-lua (fallback to vim.ui.select)
    local function org_insert_link_fzf()
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

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "org",
      callback = function()
        vim.schedule(function()
          vim.keymap.set("n", "R", function()
            require("custom.org").refile_with_fzf()
          end, { buffer = true, desc = "Refile with Fzf" })
          vim.keymap.set("n", "t", function()
            org_todo_next_state_with_working()
          end, { buffer = true, desc = "TODO next state (clock WORKING)" })
          vim.keymap.set({ "n", "v" }, "<Leader>oli", function()
            org_insert_link_fzf()
          end, { buffer = true, desc = "Insert link (fzf)" })
          vim.keymap.set("n", "<Leader>oep", function()
            local src = vim.api.nvim_buf_get_name(0)
            if src == "" or vim.fn.filereadable(src) ~= 1 then
              vim.notify("No org file to export.", vim.log.levels.WARN)
              return
            end
            -- vim.system raises on a missing executable rather than routing
            -- the failure to the callback, so the guard has to come first.
            if vim.fn.executable("pandoc") == 0 then
              vim.notify("pandoc is not installed.", vim.log.levels.ERROR)
              return
            end
            if vim.bo.modified then
              vim.cmd("write")
            end
            local pdf = vim.fn.fnamemodify(src, ":r") .. ".pdf"
            vim.notify("Exporting to PDF…", vim.log.levels.INFO)
            vim.system(
              { "pandoc", src, "-o", pdf },
              { text = true },
              vim.schedule_wrap(function(obj)
                if obj.code ~= 0 then
                  vim.notify("pandoc failed: " .. (obj.stderr or ""), vim.log.levels.ERROR)
                  return
                end
                vim.system({ "open", pdf }, { detach = true })
                vim.notify("Opened " .. pdf, vim.log.levels.INFO)
              end)
            )
          end, { buffer = true, desc = "Export to PDF (pandoc) and open" })
        end)
      end,
    })
  end,
}
