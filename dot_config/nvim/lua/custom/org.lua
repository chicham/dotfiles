-- Helpers that org capture templates call.
--
-- A capture template is a plain string that orgmode evaluates at capture time,
-- from whatever buffer the capture was fired in, so anything it names has to
-- resolve without the two org specs having run their config(). Keeping these
-- functions here, behind `require("custom.org")`, is what makes that true: the
-- templates in org-roam.lua and nvim-orgmode.lua both reach them, neither spec
-- has to be loaded for the other's templates to work, and the require itself is
-- what pulls in whichever plugin a given helper needs.
--
-- Plugin modules are therefore required inside the function bodies rather than
-- at the top of this file. Requiring one up here would load both org plugins
-- the moment any template is expanded, which is exactly the coupling this
-- module exists to remove.

local M = {}

local orgfiles_base = vim.fn.expand("~/.orgfiles")

-- Values a prompt collects for the template expansion that follows it. They are
-- fields rather than upvalues because the template strings read them directly.
--
-- Most are cleared on the next tick by the helper that set them, so the
-- following capture prompts again. `person_name` is the exception: nothing
-- clears it, and it stays readable until the next capture that prompts for a
-- person overwrites it. That is only safe because its one reader sits below the
-- prompt in the same template -- a new reader has to call
-- `prompt_person_for_capture()` itself rather than trust the field.
M.capture = {}

-- Experiment-run capture: prompt once for the project whose tracking.org
-- receives the run, and reuse it for the target path.
function M.prompt_tracking_project()
  if not M.capture.tracking_project then
    local slug = vim.fn.input("Project slug (gtd/projects/<slug>/tracking.org): ")
    M.capture.tracking_project = slug ~= "" and slug or "inbox"
    vim.schedule(function()
      M.capture.tracking_project = nil
    end)
  end
  return M.capture.tracking_project
end

-- Experiment title/slug helpers for filename
function M.prompt_experiment_title()
  if not M.capture.experiment_title then
    local title = vim.fn.input("Experiment Title: ")
    M.capture.experiment_title = title ~= "" and title or "untitled"
    M.capture.experiment_slug = M.capture.experiment_title:gsub("%s+", "-"):gsub("[^%w%-]", ""):lower()
  end
  return M.capture.experiment_title
end

function M.get_experiment_slug()
  if not M.capture.experiment_slug then
    M.prompt_experiment_title()
  end
  return M.capture.experiment_slug
end

-- Define experiment template generator (single source of truth)
-- This function is called by both capture template and promotion function
function M.get_experiment_template_sections()
  -- The title and slug belong to the capture being expanded right now, so
  -- they are cleared once it has consumed them.
  vim.schedule(function()
    M.capture.experiment_title = nil
    M.capture.experiment_slug = nil
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

function M.capture_git_root()
  if require("orgmode.utils").current_file_path() == "" then
    return ""
  end
  local dir = require("orgmode.utils.fs").get_current_file_dir()
  local result = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 or not result[1] or result[1] == "" then
    return ""
  end
  return vim.trim(result[1])
end

function M.capture_display_path()
  local path = require("orgmode.utils").current_file_path()
  if path == "" then
    return "capture"
  end
  path = vim.fn.fnamemodify(path, ":p")
  local root = M.capture_git_root()
  if root ~= "" then
    root = vim.fn.fnamemodify(root, ":p")
    if vim.startswith(path, root .. "/") then
      return path:sub(#root + 2)
    end
  end
  local rel = vim.fn.fnamemodify(path, ":.")
  if rel ~= "" and rel ~= path then
    return rel
  end
  return vim.fn.fnamemodify(path, ":t")
end

function M.capture_default_title()
  local path = require("orgmode.utils").current_file_path()
  if path == "" then
    return "capture"
  end
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  return M.capture_display_path() .. ":" .. line_nr
end

function M.capture_git_commit()
  if require("orgmode.utils").current_file_path() == "" then
    return "N/A"
  end
  local dir = require("orgmode.utils.fs").get_current_file_dir()
  local result = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "HEAD" })
  if vim.v.shell_error ~= 0 or not result[1] or result[1] == "" then
    return "N/A"
  end
  return vim.trim(result[1])
end

function M.capture_abs_link()
  local path = require("orgmode.utils").current_file_path()
  if path == "" then
    return ""
  end
  path = vim.fn.fnamemodify(path, ":p")
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local display = M.capture_default_title()
  return string.format("[[file:%s::%d][%s]]", path, line_nr, display)
end

-- Scan roam/people/**/*.org for person files (tagged :person:)
local function scan_people_files()
  local people_dir = vim.fn.expand(orgfiles_base .. "/roam/people")
  -- Match both roam/people/*.org and roam/people/*/*.org
  local files = vim.fn.glob(people_dir .. "/**/*.org", false, true)
  local people = {}

  for _, path in ipairs(files) do
    local lines = vim.fn.readfile(path, "", 20)
    local name, id, is_person
    for _, line in ipairs(lines) do
      if not name then
        name = line:match("^#+TITLE:%s*(.+)$")
      end
      if not id then
        id = line:match("^:ID:%s*(.+)$")
      end
      if not is_person and line:match("^#+FILETAGS:.*:person:") then
        is_person = true
      end
      if name and id and is_person then
        break
      end
    end
    if name and is_person then
      table.insert(people, { name = vim.trim(name), id = id or "", path = path })
    end
  end

  table.sort(people, function(a, b)
    return a.name < b.name
  end)
  return people
end

-- fzf picker: select a person, call callback({name, id, path})
function M.select_person(opts, callback)
  opts = opts or {}
  local people = scan_people_files()

  if #people == 0 then
    vim.notify("No people found in roam/people/. Create person files first.", vim.log.levels.WARN)
    return
  end

  local displays = {}
  local display_map = {}
  for _, p in ipairs(people) do
    table.insert(displays, p.name)
    display_map[p.name] = p
  end

  local function on_select(choice)
    if not choice then
      return
    end
    local person = display_map[choice]
    if person and callback then
      callback(person)
    end
  end

  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.fzf_exec(displays, {
      prompt = opts.prompt or "Person > ",
      actions = {
        ["default"] = function(selected)
          if selected and selected[1] then
            on_select(selected[1])
          end
        end,
      },
      winopts = { height = 0.4, width = 0.5 },
    })
  else
    vim.ui.select(displays, { prompt = opts.prompt or "Person > " }, on_select)
  end
end

-- For capture templates: synchronous person prompt with completion
function M.person_complete(arg_lead, _, _)
  local people = scan_people_files()
  local matches = {}
  for _, p in ipairs(people) do
    if p.name:lower():find(arg_lead:lower(), 1, true) then
      table.insert(matches, p.name)
    end
  end
  return matches
end

function M.prompt_person_for_capture()
  local input = vim.fn.input({
    prompt = "Person: ",
    -- vim resolves the completion spec itself, so it has to name the function
    -- in a form vim can evaluate; v:lua handles the require.
    completion = "customlist,v:lua.require'custom.org'.person_complete",
  })
  M.capture.person_name = input
  return input
end

-- Refile helper (fzf-lua first, fallback to vim.ui.select)
function M.refile_with_fzf(opts)
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
    local target_path = vim.fn.fnamemodify(opts.destination_path, ":p")
    for key, file in pairs(valid_destinations) do
      local file_path = vim.fn.fnamemodify(file.filename, ":p")
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

return M
