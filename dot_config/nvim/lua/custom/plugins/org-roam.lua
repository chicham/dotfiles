-- org-roam.nvim configuration
-- PKM (Personal Knowledge Management) and Journaling System
-- See full documentation at: https://github.com/chipsenkbeil/org-roam.nvim

-- The commands the `keys` table below binds. They are filled in by config(),
-- which is the only place that can build them, but the `keys` table is
-- evaluated before config() runs and so cannot see its locals -- this table is
-- the handle both halves share.
local api = {}

return {
  "chipsenkbeil/org-roam.nvim",
  tag = "0.2.0",
  -- VeryLazy rather than eager: org-roam walks the roam directory during
  -- setup, and doing that before the first screen draw costs the whole scan up
  -- front. Firing right after the draw keeps every keymap and command below
  -- available by the time anything can be typed, and lets orgmode keep the
  -- VeryLazy trigger its own spec asks for -- a `lazy = false` here overrides
  -- that spec and drags orgmode into startup too.
  event = "VeryLazy",
  dependencies = { "nvim-orgmode/orgmode" },
  keys = {
    {
      "<leader>npr",
      function()
        api.promote_reading_note()
      end,
      desc = "Promote [R]eading from inbox",
    },
    {
      "<leader>npi",
      function()
        api.promote_inbox_note()
      end,
      desc = "Promote [I]dea/note from inbox",
    },
    {
      "<leader>npe",
      function()
        api.promote_experiment()
      end,
      desc = "Promote [E]xperiment from inbox",
    },
    {
      "<leader>nph",
      function()
        api.promote_headline_to_note()
      end,
      desc = "Promote [H]eadline to own note",
    },
    {
      "<leader>nrc",
      function()
        api.cleanup_done_tasks()
      end,
      desc = "[R]efile [C]ompleted tasks from inbox",
    },
    {
      "<leader>nrT",
      function()
        api.refile_manual_to_daily()
      end,
      desc = "Manual refile to [T]oday",
    },
    {
      "<leader>nn",
      function()
        api.ensure_daily_file()
        require("orgmode").instance().capture:open_template_by_shortcut("o")
      end,
      desc = "Quick add [N]ote to today",
    },
    {
      "<leader>nss",
      function()
        api.person_overview()
      end,
      desc = "[S]upervisee overview",
    },
    {
      "<leader>nsa",
      function()
        api.assign_person()
      end,
      desc = "[S]upervisee [A]ssign to headline",
    },
    {
      "<leader>nsl",
      function()
        api.insert_person_link()
      end,
      desc = "[S]upervisee [L]ink insert",
    },
    {
      "<leader>nw",
      function()
        local roam = require("org-roam")
        local templates = roam.config.extensions.dailies.templates
        -- Pass only the "w" template so it opens directly without selection
        roam.api
          .capture_node({
            templates = { w = templates.w },
          })
          :catch(function(err)
            vim.notify("Weekly review capture failed: " .. tostring(err), vim.log.levels.ERROR)
          end)
      end,
      desc = "Create [W]eekly Review",
    },
    {
      "<leader>nW",
      function()
        api.weekly_review_view()
      end,
      desc = "[W]eekly Review View",
    },
  },
  config = function()
    -- Scratch values a promotion collects for the capture template it is
    -- about to open, aliased from the module the templates read them from.
    local org_capture = require("custom.org").capture

    local orgfiles_base = vim.fn.expand("~/.orgfiles")
    require("org-roam").setup({
      -- Main directory for org-roam files
      directory = orgfiles_base .. "/roam",

      -- Make use of existing org-files from orgmode
      org_files = {
        orgfiles_base .. "/gtd/*.org",
        orgfiles_base .. "/gtd/projects/*.org",
        orgfiles_base .. "/research/*.org",
      },

      bindings = {
        prefix = "<Leader>n",
        capture = "<prefix>c",
        find_node = "<prefix>f",
        insert_node = "<prefix>i",
        toggle_roam_buffer = "<prefix>l",
        add_alias = "<prefix>aa",
        add_origin = "<prefix>oa",
        goto_next_node = "<prefix>]",
        goto_prev_node = "<prefix>[",
        quickfix_backlinks = "<prefix>q",
      },

      -- Configure daily notes for journaling
      extensions = {
        dailies = {
          directory = "daily",
          bindings = {
            capture_today = "<prefix>dN",
            goto_today = "<prefix>dn",
            goto_date = "<prefix>dd",
            goto_prev_date = "<prefix>dp",
            goto_next_date = "<prefix>df",
            capture_tomorrow = "<prefix>dT",
            goto_tomorrow = "<prefix>dt",
            capture_yesterday = "<prefix>dY",
            goto_yesterday = "<prefix>dy",
            capture_date = "<prefix>dD",
            find_directory = "<prefix>d.",
          },
          templates = {
            d = {
              description = "Daily Log",
              template = [[
:PROPERTIES:
:ID: %(return require('orgmode.org.id').new())
:CREATED: %U
:END:
#+TITLE: %<%Y-%m-%d %A>
#+FILETAGS: :daily:

# Shortcuts: <Leader>nn=note, <Leader>nrc=cleanup done tasks, I=clock-in, O=clock-out

* Done

* Notes
]],
              target = "%<%Y-%m-%d>.org",
            },
            w = {
              description = "Weekly Review",
              template = [[
:PROPERTIES:
:ID: %(return require('orgmode.org.id').new())
:CREATED: %U
:END:
#+TITLE: Week %<%Y-W%V> Review
#+FILETAGS: :weekly:review:

* Completed This Week
%?

* In Progress
-

* Blockers
-

* Next Week
- [ ]
]],
              target = "weekly/%<%Y-W%V>-review.org",
            },
          },
        },
      },

      -- Default template content
      templates = {
        -- Default template for new notes/ideas
        n = {
          description = "note",
          template = [[
:PROPERTIES:
:ID: %(return require('orgmode.org.id').new())
:CREATED: %U
:END:
#+TITLE: %^{Title}
#+FILETAGS: :note:

* Notes
%?]],
          target = "notes/%<%Y%m%d%H%M%S>-%[slug].org",
        },
        -- Reading/Literature template - Single source of truth
        p = {
          description = "Reading/Literature",
          template = [=[
:PROPERTIES:
:ID: %(return require('custom.org').capture.roam_id or require('orgmode.org.id').new())
:CREATED: %U
:DATE_READ: %u
:AUTHOR: %(return vim.fn.input("Author(s): "))
:JOURNAL: %(return vim.fn.input("Journal/Publisher: "))
:YEAR: %(return vim.fn.input("Year: "))
:DOI: %(return vim.fn.input("DOI (optional): "))
:KEYWORDS: %(return vim.fn.input("Keywords (comma separated): "))
:END:
#+TITLE: [[%(return (require('custom.org').capture.roam_url and require('custom.org').capture.roam_url ~= "" and require('custom.org').capture.roam_url) or vim.fn.input("URL: "))][%(return (require('custom.org').capture.roam_title and require('custom.org').capture.roam_title ~= "" and require('custom.org').capture.roam_title) or vim.fn.input("Title: "))]]
#+FILETAGS: :reading:research:

* Hypothesis/Claim
# What do the authors say they are presenting that is new?
%?

* Methods


* Results


* Evidence


* Summary of Key Points
# Use quotation marks around any exact wording.


* Context & Relationships
# How does this article relate to YOUR work and to other research?


* Important Figures/Tables


* References to Follow Up


* Critical Evaluation
# Does the paper clearly identify its contribution to the field?
# Is the method used appropriate?
# Do the results match the claim?
# Is the evidence sufficient and convincing?
# What flaws/strengths do you see?
# How can this paper be helpful to your research/writing?
]=],
          target = "literature/%<%Y%m%d%H%M%S>-%[slug].org",
        },
        -- Experiment template - Single source of truth
        e = {
          description = "Experiment",
          template = [[
* %^{Status|TODO|WORKING|WAITING|DONE|CANCELLED} %(return require('custom.org').prompt_experiment_title()) :experiment:
:PROPERTIES:
:ID: %(return require('orgmode.org.id').new())
:CREATED: %U
:END:

%(return require('custom.org').get_experiment_template_sections())%?]],
          target = "../experiments/%<%Y-%m-%d>-%(return require('custom.org').get_experiment_slug()).org",
        },
      },

      ui = {
        node_buffer = {
          unique = true,
        },
      },
    })

    -- Helper: Remove headline from source file after successful refile
    local function remove_headline_from_source(source_file, item_range)
      if not source_file or not item_range then
        return
      end
      pcall(function()
        source_file:update_sync(function(file)
          local bufnr = file:get_valid_bufnr()
          vim.api.nvim_buf_set_lines(bufnr, item_range.start_line - 1, item_range.end_line, false, {})
        end)
      end)
    end

    -- Helper: Extract first org link from headline
    local function get_first_link(headline)
      if not headline then
        return nil
      end
      for _, line in ipairs(headline:get_lines() or {}) do
        local raw = line:match("%[%[(.-)%]%]")
        if raw then
          local url = raw:match("^(.-)%]%[") or raw
          if url and url ~= "" then
            return url
          end
        end
      end
      return nil
    end

    -- Consolidated promote function - converts inbox headlines to org-roam notes
    local function promote_headline(config)
      local org = require("orgmode")
      local source_file = org.instance().files:get_current_file()
      local source_headline = source_file and source_file:get_closest_headline()

      if not source_headline then
        vim.notify("No headline found.", vim.log.levels.WARN)
        return
      end

      -- Validate tags
      local tags = source_headline:get_tags()
      local has_valid_tag = false
      for _, tag in ipairs(config.tags) do
        if vim.tbl_contains(tags, tag) then
          has_valid_tag = true
          break
        end
      end

      if not has_valid_tag then
        local tag_str = table.concat(
          vim.tbl_map(function(t)
            return ":" .. t .. ":"
          end, config.tags),
          " or "
        )
        vim.notify("Headline is not tagged " .. tag_str, vim.log.levels.WARN)
        return
      end

      local title = vim.trim(source_headline:get_title() or "")
      if title == "" then
        vim.notify("No title found.", vim.log.levels.WARN)
        return
      end

      local item_range = source_headline:get_range()
      local roam = require("org-roam")

      -- Handle reading-specific logic (URL extraction)
      if config.require_url then
        local status, org_id_module = pcall(require, "orgmode.org.id")
        if not status then
          vim.notify("Error loading orgmode.org.id", vim.log.levels.ERROR)
          return
        end

        org_capture.roam_id = org_id_module.new()
        org_capture.roam_title = title
        org_capture.roam_url = get_first_link(source_headline)

        if not org_capture.roam_url or org_capture.roam_url == "" then
          org_capture.roam_url = vim.fn.input("URL: ")
        end
      end

      -- Prepare template with absolute target path
      local template_config = vim.deepcopy(roam.config.templates[config.template])
      if template_config.target then
        -- Ensure target is absolute by joining with roam directory
        local target = template_config.target
        -- Expand date format
        target = target:gsub("%%<([^>]+)>", function(fmt)
          return os.date(fmt)
        end)
        -- Create slug from title
        local slug = require("org-roam.utils").title_to_slug(title)
        target = target:gsub("%%[slug]", slug)
        -- Make absolute path
        template_config.target = vim.fs.joinpath(vim.fn.expand(roam.config.directory), target)
      end

      if config.check_existing_by_title and template_config.target then
        local slug = require("org-roam.utils").title_to_slug(title)
        local target_dir = vim.fn.fnamemodify(template_config.target, ":h")
        local slug_pattern = "%-" .. vim.pesc(slug) .. "%.org$"
        local matches = vim.fs.find(function(name, _)
          return name:match(slug_pattern) or name == slug .. ".org"
        end, { path = target_dir, type = "file", limit = 1 })
        if matches and #matches > 0 then
          vim.cmd("edit " .. vim.fn.fnameescape(matches[1]))
          vim.notify("Reading note already exists: " .. matches[1], vim.log.levels.WARN)
          return
        end
      end

      -- Use native org-roam capture API with modified template
      roam.api
        .capture_node({
          title = title,
          origin = false,
          templates = { [config.template] = template_config },
        })
        :next(function(id)
          if id then
            -- Delete the original headline from inbox
            remove_headline_from_source(source_file, item_range)
            vim.notify("Promoted to roam note: " .. title, vim.log.levels.INFO)

            -- Cleanup globals for reading promotion
            if config.require_url then
              org_capture.roam_id = nil
              org_capture.roam_title = nil
              org_capture.roam_url = nil
            end
          else
            vim.notify("Promotion cancelled or failed", vim.log.levels.WARN)
          end
        end)
        :catch(function(err)
          vim.notify("Error promoting: " .. tostring(err), vim.log.levels.ERROR)
        end)
    end

    -- Promote reading list entry
    function api.promote_reading_note()
      promote_headline({ tags = { "reading" }, template = "p", require_url = true, check_existing_by_title = true })
    end

    -- Promote note or idea
    function api.promote_inbox_note()
      promote_headline({ tags = { "note", "idea" }, template = "n" })
    end

    -- Promote any headline to its own note (no tag restriction)
    function api.promote_headline_to_note()
      promote_headline({ tags = {}, template = "n" })
    end

    -- Promote any headline to its own experiment file
    function api.promote_experiment()
      promote_headline({ tags = {}, template = "e" })
    end

    -- Ensure daily file exists (creates from template if missing)
    function api.ensure_daily_file(time)
      local roam = require("org-roam")
      local base_dir = vim.fn.expand(roam.config.directory)
      local daily_dir = roam.config.extensions.dailies.directory or "daily"
      local t = time or os.time()
      local date_str = os.date("%Y-%m-%d", t)
      local path = vim.fs.joinpath(base_dir, daily_dir, date_str .. ".org")

      if vim.fn.filereadable(path) == 0 then
        local template_cfg = roam.config.extensions.dailies.templates.d
        if not template_cfg then
          vim.notify("Daily template 'd' not found", vim.log.levels.ERROR)
          return nil
        end

        -- Expand template placeholders with the target time
        local content = template_cfg.template
        content = content:gsub("%%%(return require%('orgmode%.org%.id'%)%.new%(%)%)", function()
          local ok, id_mod = pcall(require, "orgmode.org.id")
          return ok and id_mod.new() or "TEMP-ID"
        end)
        content = content:gsub("%%U", os.date("[%Y-%m-%d %a %H:%M]", t))
        content = content:gsub("%%<([^>]+)>", function(fmt)
          return os.date(fmt, t)
        end)

        vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
        vim.fn.writefile(vim.split(content, "\n"), path)
      end

      return path
    end

    -- Auto-refile completed tasks to their respective daily Done sections based on CLOSED date
    -- @param source_path: path to source file (required)
    -- @param tag_filter: optional tag to filter headlines (nil = no filter)
    local function cleanup_done_tasks(source_path, tag_filter)
      local org = require("orgmode").instance()
      local file_path = vim.fn.expand(source_path)

      if not file_path or file_path == "" then
        vim.notify("Source file path is required", vim.log.levels.WARN)
        return
      end

      file_path = vim.fn.resolve(vim.fn.fnamemodify(file_path, ":p"))

      -- Load source file using internal API
      local source_file = org.files:get(file_path)
      if not source_file then
        vim.notify("Source file not found: " .. file_path, vim.log.levels.WARN)
        return
      end

      -- Collect identifying info for done headlines (not the objects themselves)
      -- We store title + closed date components to re-find them after each refile
      local function collect_done_info(file, filter)
        local result = {}
        local function traverse(headlines)
          for _, h in ipairs(headlines) do
            local closed = h:get_closed_date()
            local is_done = h:is_done()
            local title = h:get_title()
            local tags = h:get_tags()

            local matches_tag = true
            if filter then
              matches_tag = vim.tbl_contains(tags, filter)
            end

            if matches_tag and is_done and closed then
              table.insert(result, {
                title = title,
                closed_year = closed.year,
                closed_month = closed.month,
                closed_day = closed.day,
              })
            end

            -- Recurse into children
            local children = h:get_child_headlines()
            if children and #children > 0 then
              traverse(children)
            end
          end
        end
        traverse(file:get_headlines())
        return result
      end

      local done_info = collect_done_info(source_file, tag_filter)

      if #done_info == 0 then
        local filter_msg = tag_filter and (" with tag :" .. tag_filter .. ":") or ""
        vim.notify("No completed tasks found" .. filter_msg, vim.log.levels.INFO)
        return
      end

      local refiled_count = 0
      local errors = {}

      -- Process each task by re-finding it fresh after each refile
      for _, info in ipairs(done_info) do
        -- Reload source file to get fresh state
        source_file = org.files:get(file_path)
        if not source_file then
          table.insert(errors, info.title .. " (source gone)")
          goto continue
        end

        -- Find the headline by matching title and closed date components
        local function find_headline(file, title, y, m, d)
          local function traverse(headlines)
            for _, h in ipairs(headlines) do
              local closed = h:get_closed_date()
              if
                h:is_done()
                and h:get_title() == title
                and closed
                and closed.year == y
                and closed.month == m
                and closed.day == d
              then
                return h
              end
              local children = h:get_child_headlines()
              if children and #children > 0 then
                local found = traverse(children)
                if found then
                  return found
                end
              end
            end
            return nil
          end
          return traverse(file:get_headlines())
        end

        local source_headline =
          find_headline(source_file, info.title, info.closed_year, info.closed_month, info.closed_day)
        if not source_headline then
          table.insert(errors, info.title .. " (not found)")
          goto continue
        end

        -- Ensure parent headline has an ID (if exists)
        local parent_headline = source_headline:get_parent_headline()
        local parent_id = nil
        if parent_headline then
          parent_id = parent_headline:get_property("ID", false)
          if not parent_id or parent_id == "" then
            local ok, id_mod = pcall(require, "orgmode.org.id")
            if ok then
              parent_id = id_mod.new()
              parent_headline:set_property("ID", parent_id)
            end
          end
        end

        -- Build time from closed date components
        local time = os.time({ year = info.closed_year, month = info.closed_month, day = info.closed_day, hour = 12 })

        -- Ensure daily file exists
        local daily_path = api.ensure_daily_file(time)

        if not daily_path then
          table.insert(errors, info.title .. " (no daily)")
          goto continue
        end

        -- Load destination file
        local dest_file = org.files:get(daily_path)
        if not dest_file then
          table.insert(errors, info.title .. " (daily not loaded)")
          goto continue
        end

        -- Find "Done" headline in destination
        local dest_headline = dest_file:find_headline_by_title("Done")
        if not dest_headline then
          table.insert(errors, info.title .. " (no Done section)")
          goto continue
        end

        -- Perform refile using internal API
        local target_line = dest_headline:get_range().end_line
        local target_level = dest_headline:get_level()
        local is_same_file = source_file.filename == dest_file.filename

        local lines = source_headline:get_lines()

        -- Add parent link if parent exists
        if parent_id and parent_headline then
          local parent_title = parent_headline:get_title()
          local parent_link = string.format("- Parent: [[id:%s][%s]]", parent_id, parent_title)
          -- Insert after the headline (skip headline line and properties drawer)
          local insert_at = 1
          for i, line in ipairs(lines) do
            if i > 1 and not line:match("^%s*:") and not line:match("^%s*$") then
              insert_at = i
              break
            end
          end
          if insert_at == 1 and #lines > 1 then
            insert_at = 2
          end
          table.insert(lines, insert_at, parent_link)
        end

        -- Adapt headline level
        local level = source_headline:get_level()
        if target_level > 0 and level <= target_level then
          local diff = target_level - level + 1
          for i, line in ipairs(lines) do
            if line:match("^%*+") then
              lines[i] = string.rep("*", diff) .. line
            end
          end
        elseif target_level > 0 and level > target_level + 1 then
          local diff = level - target_level - 1
          for i, line in ipairs(lines) do
            local stars = line:match("^(%*+)")
            if stars and #stars > diff then
              lines[i] = line:sub(diff + 1)
            end
          end
        end

        -- Insert into destination
        dest_file:update_sync(function()
          vim.api.nvim_buf_set_lines(0, target_line, target_line, false, lines)
        end)

        -- Remove from source (if different file)
        if not is_same_file then
          source_file:update_sync(function()
            local range = source_headline:get_range()
            vim.api.nvim_buf_set_lines(0, range.start_line - 1, range.end_line, false, {})
          end)
        end

        refiled_count = refiled_count + 1

        ::continue::
      end

      -- Report results
      if refiled_count > 0 then
        vim.notify(string.format("Refiled %d task(s)", refiled_count), vim.log.levels.INFO)
      end
      if #errors > 0 then
        vim.notify("Failed: " .. table.concat(errors, ", "), vim.log.levels.WARN)
      end
    end

    -- Refile headline to a selected daily headline
    local function refile_headline_to_daily(time)
      local org = require("orgmode").instance()
      local source_headline = org.files:get_current_file():get_closest_headline()

      if not source_headline then
        vim.notify("No headline found under cursor.", vim.log.levels.WARN)
        return
      end

      -- Ensure daily file exists
      local path = api.ensure_daily_file(time)
      if not path then
        vim.notify("Unable to create daily note.", vim.log.levels.WARN)
        return
      end

      local dest_file = org.files:get(path)
      if not dest_file then
        vim.notify("Daily file not available: " .. path, vim.log.levels.WARN)
        return
      end

      local source_bufnr = source_headline.file and source_headline.file:bufnr()

      require("custom.org").refile_with_fzf({
        source_headline = source_headline,
        source_bufnr = source_bufnr,
        destination_path = path,
        ensure_path = path,
        default_headline = "Notes",
        prompt = ("Daily Refile (%s)> "):format(os.date("%Y-%m-%d", time)),
        message = ("Logged to Daily: %s"):format(os.date("%Y-%m-%d", time)),
      })
    end

    -- Cleanup: auto-refile completed tasks from inbox to their respective daily notes
    function api.cleanup_done_tasks(source_path, tag_filter)
      -- Default to inbox if no source specified
      local path = source_path or vim.fn.expand("~/.orgfiles/gtd/inbox.org")
      cleanup_done_tasks(path, tag_filter)
    end

    -- Manual refile current headline to today's daily
    function api.refile_manual_to_daily()
      refile_headline_to_daily(os.time())
    end

    -- Weekly review view: show all tasks and notes from the past 7 days
    function api.weekly_review_view()
      local roam = require("org-roam")
      local base_dir = vim.fn.expand(roam.config.directory)
      local daily_dir = roam.config.extensions.dailies.directory or "daily"
      local daily_path = vim.fs.joinpath(base_dir, daily_dir)

      local now = os.time()
      local day_seconds = 24 * 60 * 60
      local items = {}

      -- Collect items from past 7 days
      for i = 0, 6 do
        local time = now - (i * day_seconds)
        local date_str = os.date("%Y-%m-%d", time)
        local weekday = os.date("%a", time)
        local file_path = vim.fs.joinpath(daily_path, date_str .. ".org")

        if vim.fn.filereadable(file_path) == 1 then
          local lines = vim.fn.readfile(file_path)
          local current_section = nil
          local current_level = 0

          for lnum, line in ipairs(lines) do
            -- Detect section headlines (Done, Notes)
            local stars, title = line:match("^(%*+)%s+(.+)$")
            if stars then
              local level = #stars
              local clean_title = title:gsub("%s*%[.-%]%s*", ""):gsub("%s*:.+:%s*$", "")
              if level == 1 and (clean_title == "Done" or clean_title == "Notes") then
                current_section = clean_title
                current_level = level
              elseif level == 1 then
                current_section = nil
              elseif current_section and level > current_level then
                -- This is a child headline under a tracked section
                local display = string.format("%s %s | %-7s | %s", date_str, weekday, current_section, title)
                table.insert(items, {
                  display = display,
                  file = file_path,
                  lnum = lnum,
                  date = date_str,
                  section = current_section,
                })
              end
            end
          end
        end
      end

      if #items == 0 then
        vim.notify("No items found in the past 7 days.", vim.log.levels.INFO)
        return
      end

      -- Build display list
      local displays = {}
      for _, item in ipairs(items) do
        table.insert(displays, item.display)
      end

      -- Use fzf-lua if available, otherwise vim.ui.select
      local ok, fzf = pcall(require, "fzf-lua")
      if ok then
        fzf.fzf_exec(displays, {
          prompt = "Weekly Review> ",
          actions = {
            ["default"] = function(selected)
              if selected and selected[1] then
                for _, item in ipairs(items) do
                  if item.display == selected[1] then
                    vim.cmd("edit " .. vim.fn.fnameescape(item.file))
                    vim.api.nvim_win_set_cursor(0, { item.lnum, 0 })
                    break
                  end
                end
              end
            end,
          },
          winopts = {
            height = 0.6,
            width = 0.8,
          },
        })
      else
        vim.ui.select(displays, { prompt = "Weekly Review> " }, function(choice)
          if choice then
            for _, item in ipairs(items) do
              if item.display == choice then
                vim.cmd("edit " .. vim.fn.fnameescape(item.file))
                vim.api.nvim_win_set_cursor(0, { item.lnum, 0 })
                break
              end
            end
          end
        end)
      end
    end

    -- =========================================================================
    -- People tracking helpers
    -- =========================================================================

    -- Open a person's file (dashboard). Use <Leader>nl for backlinks.
    function api.person_overview()
      require("custom.org").select_person({ prompt = "Open person > " }, function(person)
        vim.cmd("edit " .. vim.fn.fnameescape(person.path))
      end)
    end

    -- Assign :PERSON: property to the headline under cursor
    function api.assign_person()
      require("custom.org").select_person({ prompt = "Assign person > " }, function(person)
        local org = require("orgmode")
        local headline = org.instance().files:get_current_file():get_closest_headline()
        if not headline then
          vim.notify("No headline found under cursor.", vim.log.levels.WARN)
          return
        end
        headline:set_property("PERSON", person.name)
        vim.notify("Assigned: " .. person.name, vim.log.levels.INFO)
      end)
    end

    -- Insert [[id:UUID][Name]] link to a person at cursor position
    function api.insert_person_link()
      require("custom.org").select_person({ prompt = "Link person > " }, function(person)
        if not person.id or person.id == "" then
          vim.notify("Person has no :ID: property: " .. person.name, vim.log.levels.WARN)
          return
        end
        local link = string.format("[[id:%s][%s]]", person.id, person.name)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_get_current_line()
        local new_line = line:sub(1, col) .. link .. line:sub(col + 1)
        vim.api.nvim_set_current_line(new_line)
        vim.api.nvim_win_set_cursor(0, { row, col + #link })
      end)
    end

    -- Keymaps are defined in the lazy.nvim keys table.
  end,
}
