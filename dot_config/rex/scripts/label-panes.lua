-- Label every terminal pane with the project it is in.
--
-- Run with `rex do ~/.config/rex/scripts/label-panes.lua --all`; the
-- local.rex.label-panes LaunchAgent keeps it running.
--
-- Label: the name of the enclosing jj or git repository. Inside a jj
-- workspace at <repo>/.workspaces/<name> it is "<repo>:<name>". Outside a
-- repository it is the directory's own name, and "~" for the home directory.

local HOME = os.getenv("HOME") or ""

-- ev.pwd is a file:// URL: drop the scheme and host, decode %XX escapes.
local function url_to_path(url)
  local path = url:gsub("^file://[^/]*", "")
  path = path:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
  if #path > 1 then path = path:gsub("/+$", "") end
  return path
end

local function exists(path)
  local file = io.open(path, "r")
  if file then file:close() end
  return file ~= nil
end

-- Files rather than directories, because io.open can't test a directory:
-- .jj/working_copy/checkout exists in every jj workspace, .git/HEAD in a git
-- repository, and a plain .git file in a git worktree.
local function is_repo_root(dir)
  return exists(dir .. "/.jj/working_copy/checkout")
      or exists(dir .. "/.git/HEAD")
      or exists(dir .. "/.git")
end

local function basename(path)
  return path:match("([^/]+)$") or path
end

local function project_label(path)
  local dir = path
  while dir ~= "" and dir ~= "/" do
    if is_repo_root(dir) then
      local repo, workspace = dir:match("^(.*)/%.workspaces/([^/]+)$")
      if repo then return basename(repo) .. ":" .. workspace end
      return basename(dir)
    end
    dir = dir:match("^(.*)/[^/]*$") or ""
  end
  if path == HOME then return "~" end
  return basename(path)
end

local last_label = {}

rex.on("terminal.pwd_changed", function(ctx, ev)
  local label = project_label(url_to_path(ev.pwd))
  -- Skip the call when a cd stays inside the same project.
  if last_label[ctx.block_id] == label then return end
  local _, err = rex.session.set_block_label{
    session_id = ctx.session_id,
    block_id   = ctx.block_id,
    label      = label,
  }
  if err then
    rex.log("warn", "label-panes: " .. tostring(err))
    return
  end
  last_label[ctx.block_id] = label
end)

rex.on("block_closed", function(ctx, ev)
  last_label[ev.block_id] = nil
end)
