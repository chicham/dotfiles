-- org-roam.nvim configuration
-- PKM (Personal Knowledge Management) and Journaling System
-- See full documentation at: https://github.com/chipsenkbeil/org-roam.nvim

return {
  "chipsenkbeil/org-roam.nvim",
  tag = "0.2.0",
  lazy = false, -- Ensure it loads so keymaps are available
  dependencies = {
    { "nvim-orgmode/orgmode", lazy = false },
  },
  keys = {
    { "<leader>npr", function() _G.org_promote_reading_note() end, desc = "Promote [R]eading from inbox" },
    { "<leader>npn", function() _G.org_promote_inbox_note() end, desc = "Promote [N]ote or idea from inbox" },
    { "<leader>npx", function() _G.org_promote_experiment() end, desc = "Promote e[X]periment from inbox" },
    { "<leader>nrt", function() _G.org_refile_to_daily() end, desc = "Refile to [R]efiles [T]oday" },
    { "<leader>nry", function() _G.org_refile_to_yesterday() end, desc = "Refile to [R]efiles [Y]esterday" },
    {
      "<leader>nt",
      function()
        if _G.ensure_daily_capture_targets then
          _G.ensure_daily_capture_targets()
        end
        require("orgmode").instance().capture:open_template_by_shortcut("j")
      end,
      desc = "Quick add [t]ask to today",
    },
    {
      "<leader>ne",
      function()
        if _G.ensure_daily_capture_targets then
          _G.ensure_daily_capture_targets()
        end
        require("orgmode").instance().capture:open_template_by_shortcut("o")
      end,
      desc = "Quick add not[e] to today",
    },
    {
      "<leader>nw",
      function()
        capture_roam_dailies_template(os.time(), "w")
      end,
      desc = "Create [W]eekly Review",
    },
  },
  config = function()
    require("org-roam").setup({
      -- Main directory for org-roam files
      directory = "~/.orgfiles/roam",

      -- Make use of existing org-files from orgmode
      org_files = {
        "~/.orgfiles/gtd/*.org",
        "~/.orgfiles/gtd/projects/*.org",
        "~/.orgfiles/research/*.org",
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

# Shortcuts: <Leader>nt=task, <Leader>ne=note, <Leader>nrt=refile today, <Leader>nry=refile yesterday, I=clock-in, O=clock-out

* Planned [/]
  %?

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
          template = "%?",
          target = "%[slug].org",
        },
        -- Reading/Literature template - Single source of truth
            p = {
              description = "Reading/Literature",
              template = [[
:PROPERTIES:
:ID: %(return _G.org_roam_capture_id or require('orgmode.org.id').new())
:CREATED: %U
:URL: %(return (_G.org_roam_capture_url and _G.org_roam_capture_url ~= "" and _G.org_roam_capture_url) or vim.fn.input("URL: "))
:DATE_READ: %u
:AUTHOR: %(return vim.fn.input("Author(s): "))
:JOURNAL: %(return vim.fn.input("Journal/Publisher: "))
:YEAR: %(return vim.fn.input("Year: "))
:DOI: %(return vim.fn.input("DOI (optional): "))
:KEYWORDS: %(return vim.fn.input("Keywords (comma separated): "))
:END:
#+TITLE: %(return (_G.org_roam_capture_title and _G.org_roam_capture_title ~= "" and _G.org_roam_capture_title) or vim.fn.input("Title: "))
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
]],
              target = "literature/%<%Y%m%d%H%M%S>-%[slug].org",
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
        local tag_str = table.concat(vim.tbl_map(function(t) return ":" .. t .. ":" end, config.tags), " or ")
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

        _G.org_roam_capture_id = org_id_module.new()
        _G.org_roam_capture_title = title
        _G.org_roam_capture_url = get_first_link(source_headline)

        if not _G.org_roam_capture_url or _G.org_roam_capture_url == "" then
          _G.org_roam_capture_url = vim.fn.input("URL: ")
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

      -- Use native org-roam capture API with modified template
      roam.api.capture_node({
        title = title,
        origin = false,
        templates = { [config.template] = template_config },
      }):next(function(id)
        if id then
          -- Delete the original headline from inbox
          remove_headline_from_source(source_file, item_range)
          vim.notify("Promoted to roam note: " .. title, vim.log.levels.INFO)

          -- Cleanup globals for reading promotion
          if config.require_url then
            _G.org_roam_capture_id = nil
            _G.org_roam_capture_title = nil
            _G.org_roam_capture_url = nil
          end
        else
          vim.notify("Promotion cancelled or failed", vim.log.levels.WARN)
        end
      end):catch(function(err)
        vim.notify("Error promoting: " .. tostring(err), vim.log.levels.ERROR)
      end)
    end

    -- Promote reading list entry
    _G.org_promote_reading_note = function()
      promote_headline({ tags = { "reading" }, template = "p", require_url = true })
    end

    -- Promote note or idea
    _G.org_promote_inbox_note = function()
      promote_headline({ tags = { "note", "idea" }, template = "n" })
    end

    -- Promote experiment to project logbook
    _G.org_promote_experiment = function()
      local org = require("orgmode")
      local source_file = org.instance().files:get_current_file()
      local source_headline = source_file and source_file:get_closest_headline()

      if not source_headline then
        vim.notify("No headline found.", vim.log.levels.WARN)
        return
      end

      if not vim.tbl_contains(source_headline:get_tags(), "experiment") then
        vim.notify("Headline is not tagged :experiment:", vim.log.levels.WARN)
        return
      end

      local project = source_headline:get_property("PROJECT", false) or vim.fn.input("Experiment project: ")
      if project == "" then
        vim.notify("Project is required.", vim.log.levels.WARN)
        return
      end

      local logbook = vim.g.org_experiment_logbook_name or "logbook.org"
      local path = vim.fn.expand("~/.orgfiles/gtd/projects/" .. project .. "/" .. logbook)

      -- Ensure logbook exists with Experiments headline
      if vim.fn.filereadable(path) == 0 then
        local status, org_id_module = pcall(require, "orgmode.org.id")
        local org_id = status and org_id_module.new() or "TEMP-ID"
        vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
        vim.fn.writefile({
          ":PROPERTIES:",
          ":ID: " .. org_id,
          ":CREATED: " .. os.date("[%Y-%m-%d %a %H:%M]"),
          ":PROJECT: " .. project,
          ":END:",
          "#+TITLE: " .. project .. " Experiment Logbook",
          "#+FILETAGS: :experiment:logbook:",
          "",
          "* Experiments",
        }, path)
      end

      local dest_file = org.instance().files:get(path)
      local dest_headline = dest_file and dest_file:find_headline_by_title("Experiments")

      if not dest_file or not dest_headline then
        vim.notify("Missing Experiments headline in logbook.", vim.log.levels.WARN)
        return
      end

      local item_range = source_headline:get_range()
      org.instance().capture:_refile_from_org_file({
        source_headline = source_headline,
        destination_file = dest_file,
        destination_headline = dest_headline,
      })

      remove_headline_from_source(source_file, item_range)
    end

    -- Ensure daily file exists (using native org-roam dailies API)
    _G.org_roam_ensure_daily_file = function(time)
      local roam = require("org-roam")
      local date_obj = time and require("orgmode.objects.date").from_timestamp(time) or require("orgmode.objects.date").today()

      -- Use native goto_date which creates file if not exists
      roam.extensions.dailies.goto_date({ date = date_obj }):next(function()
        local path = vim.api.nvim_buf_get_name(0)
        -- Ensure headlines exist after creation
        if _G.ensure_daily_capture_targets then
          _G.ensure_daily_capture_targets()
        end
        return path
      end)

      -- Fallback: construct path manually
      local base_dir = vim.fn.expand(roam.config.directory)
      local daily_dir = roam.config.extensions.dailies.directory or "daily"
      local date_str = os.date("%Y-%m-%d", time or os.time())
      return vim.fs.joinpath(base_dir, daily_dir, date_str .. ".org")
    end

    -- Refile headline to daily's Done section
    local function refile_headline_to_daily(time)
      local org = require("orgmode").instance()
      local source_headline = org.files:get_current_file():get_closest_headline()

      if not source_headline then
        vim.notify("No headline found under cursor.", vim.log.levels.WARN)
        return
      end

      -- Ensure daily file exists
      local path = _G.org_roam_ensure_daily_file(time)
      if not path then
        vim.notify("Unable to create daily note.", vim.log.levels.WARN)
        return
      end

      local dest_file = org.files:get(path)
      if not dest_file then
        vim.notify("Daily file not available: " .. path, vim.log.levels.WARN)
        return
      end

      -- Find "Done" headline
      local dest_headline = nil
      for _, hl in ipairs(dest_file:get_headlines()) do
        if hl:get_title():match("Done") then
          dest_headline = hl
          break
        end
      end

      org.capture:_refile_from_org_file({
        source_headline = source_headline,
        destination_file = dest_file,
        destination_headline = dest_headline,
      })

      return path
    end

    -- Refile to today's daily
    _G.org_refile_to_daily = function()
      local time = os.time()
      if refile_headline_to_daily(time) then
        vim.notify("Logged to Daily: " .. os.date("%Y-%m-%d", time), vim.log.levels.INFO)
      end
    end

    -- Refile to yesterday's daily
    _G.org_refile_to_yesterday = function()
      local time = os.time() - (24 * 60 * 60)
      if refile_headline_to_daily(time) then
        vim.notify("Logged to Daily: " .. os.date("%Y-%m-%d", time), vim.log.levels.INFO)
      end
    end

    -- Keymaps are defined in the lazy.nvim keys table.
  end,
}
