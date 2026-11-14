--- Org-format exchange between the quickfix review list and an agent.
---
--- Two files live at the workspace root:
---
---   .review.org      review comments. Written by nvim, annotated by the agent.
---   .nvim-state.org  editor state. Written by nvim, read-only for the agent.
---
--- `.review.org` has two writers, so ownership is split by field rather than by
--- file: nvim owns the heading, the tag and the anchor properties; the agent
--- owns the TODO keyword and the four resolution properties. Writing it is a
--- read-modify-write -- the agent's fields are re-read and carried across by
--- `:REVIEW_ID:` -- so neither side can clobber the other. `:REPLY:` is the one
--- exception: both sides write it, last writer wins, and on a REOPENED heading
--- it holds the user's rebuttal rather than the agent's reason.
---
--- Identity is derived, not stored: `:REVIEW_ID:` is a hash of the path and the
--- comment text. It survives a fix moving the anchored line, which `file:line`
--- does not, and it cannot be lost the way a generated id in `user_data` can.
--- Two identical comments on one file collide, and are then interchangeable.
local M = {}

M.REVIEW_FILE = ".review.org"
M.STATE_FILE = ".nvim-state.org"

--- Keywords left of the bar are open. The agent can only ever set one of those,
--- so the drain gate -- no heading left of the bar -- is reachable only by the
--- user, and a proposed resolution never closes a comment on its own.
M.TODO_LINE =
  "#+TODO: TODO(t) FIXED(f) WONTFIX(x) ANSWERED(a) ACK(k) REOPENED(r) | DONE(d) CANCELLED(c)"

--- Split a `#+TODO:` line into its two halves, so the sequence is defined once
--- and the sets cannot drift from the line the file actually carries.
---@param line string
---@return table<string, boolean> open, table<string, boolean> done
local function split_sequence(line)
  local open, done, past_bar = {}, {}, false
  for word in line:gsub("^#%+TODO:", ""):gmatch("%S+") do
    if word == "|" then
      past_bar = true
    else
      local keyword = word:match("^(%u+)")
      if keyword then
        local half = past_bar and done or open
        half[keyword] = true
      end
    end
  end
  return open, done
end

M.OPEN_KEYWORDS, M.DONE_KEYWORDS = split_sequence(M.TODO_LINE)

--- Set by the agent, carried across a re-export untouched.
M.AGENT_PROPS = { "RESOLUTION", "REPLY", "CHANGE", "RESOLVED_AT" }

--- Written once, at the comment's first export, and preserved afterwards.
--- ANCHOR_HASH is the pre-check baseline: recomputing it later would compare the
--- fixed file against itself and always report "unchanged".
local WRITE_ONCE_PROPS = { "ANCHOR_HASH", "CREATED" }

--- A quickfix entry is a review comment only if it carries the plugin's own
--- `[TYPE]` / `[TYPE:L12-14]` prefix. Everything else in the list -- compiler
--- diagnostics from vimtex, `:grep` hits -- is not, and must never reach the
--- review file, where it would make the drain gate unreachable.
---@param item table Quickfix item.
---@return boolean
function M.is_review_comment(item)
  return item.text ~= nil and item.text:match("^%[%u+[:%]]") ~= nil
end

---@return table[] Review comments in the current quickfix list.
function M.review_items()
  return vim.tbl_filter(M.is_review_comment, vim.fn.getqflist())
end

--- Resolve the workspace root the exchange files live at.
---
--- The nearest `.jj` or `.git` above the anchor, not the cwd: a jj workspace
--- carries its own `.jj`, so a review taken inside one lands at the workspace
--- root. The anchor is the first comment's file when there is one -- that
--- comment names what the review is about -- and the current buffer otherwise.
---@return string
function M.root()
  local anchor
  local first = M.review_items()[1]
  if first and first.bufnr and first.bufnr ~= 0 then
    anchor = vim.api.nvim_buf_get_name(first.bufnr)
  end
  if not anchor or anchor == "" then
    anchor = vim.api.nvim_buf_get_name(0)
  end

  return (anchor ~= "" and vim.fs.root(anchor, { ".jj", ".git" }))
    or vim.fs.root(0, { ".jj", ".git" })
    or vim.fn.getcwd()
end

---@param name string Basename, e.g. `M.REVIEW_FILE`.
---@return string
function M.path(name)
  return M.root() .. "/" .. name
end

--- Path relative to `root`, so a reference resolves the same from any cwd.
---
--- Both sides are symlink-resolved first. A quickfix item carries `filename`
--- as the plugin recorded it while `getqflist` hands back only `bufnr`, whose
--- name Neovim has already resolved; on a path through a symlink -- `/tmp` and
--- `/var` on macOS both are -- those two spellings differ, the prefix fails to
--- strip, and the same comment hashes to two different `:REVIEW_ID:` values
--- depending on which side asked.
---@param file string
---@param root string
---@return string
local function relpath(file, root)
  file = vim.fs.normalize(vim.fn.resolve(file))
  local prefix = vim.fs.normalize(vim.fn.resolve(root)) .. "/"
  if file:sub(1, #prefix) == prefix then
    return file:sub(#prefix + 1)
  end
  return file
end

M.relpath = relpath

--- Rebuild the `[TYPE...]` prefix the plugin stores in the quickfix text, so a
--- re-export of an imported comment is identical to the entry it came from.
---@param kind string Upper-case comment type.
---@param lnum integer
---@param end_lnum integer
---@param col integer?
---@param end_col integer?
---@param text string
---@return string
function M.qf_text(kind, lnum, end_lnum, col, end_col, text)
  if col and end_col then
    if lnum ~= end_lnum then
      return string.format("[%s:L%d:%d-L%d:%d] %s", kind, lnum, col, end_lnum, end_col, text)
    end
    return string.format("[%s:L%d:%d-%d] %s", kind, lnum, col, end_col, text)
  elseif lnum ~= end_lnum then
    return string.format("[%s:L%d-%d] %s", kind, lnum, end_lnum, text)
  end
  return string.format("[%s] %s", kind, text)
end

--- Split a quickfix text into its type and its canonical body.
---
--- The body is what `:REVIEW_ID:` hashes, so the ` → KEYWORD` suffix an import
--- appends for display is stripped here. Leaving it in would give a comment a
--- new id the moment a resolution was proposed on it, orphaning that
--- resolution on the next export.
---
--- Only a suffix naming a keyword of the sequence is stripped: a comment may
--- legitimately end in an arrow and a capitalised word -- "renommer pq → RQ" --
--- and cutting that would silently truncate the user's text.
---@param text string Quickfix text, `[TYPE]` prefix included.
---@return string kind, string body
local function split_type(text)
  local kind = text:match("^%[(%u+)") or "QUESTION"
  local body = text:gsub("^%[[^%]]*%]%s*", "")
  local stripped, suffix = body:match("^(.-)%s*→%s*(%u+)%s*$")
  if suffix and (M.OPEN_KEYWORDS[suffix] or M.DONE_KEYWORDS[suffix]) then
    body = stripped
  end
  return kind, body
end

---@param relative_file string
---@param body string Comment text without its `[TYPE]` prefix.
---@return string Eight hex characters.
local function review_id(relative_file, body)
  return vim.fn.sha256(relative_file .. "\0" .. body):sub(1, 8)
end

--- Hash of the lines a comment is anchored to, as they read now.
---
--- The pre-check compares this against the `:ANCHOR_HASH:` captured when the
--- comment was first exported: differing means the file changed where the
--- comment points, which is weak evidence that a proposed fix was applied
--- there. Returns an empty string when the file cannot be read, which the
--- pre-check reports as unknown rather than as a pass.
---@param file string Absolute path.
---@param lnum integer
---@param end_lnum integer
---@return string
function M.anchor_hash(file, lnum, end_lnum)
  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok or type(lines) ~= "table" then
    return ""
  end
  local slice = {}
  for i = lnum, math.min(end_lnum, #lines) do
    slice[#slice + 1] = lines[i]
  end
  if #slice == 0 then
    return ""
  end
  return vim.fn.sha256(table.concat(slice, "\n")):sub(1, 8)
end

--- Lines of the `:ReviewResolutions` preview for one comment.
---
--- A resolution is judged against the whole comment, what the agent proposes,
--- its reply, and the anchored lines as they read now -- none of which fits on
--- a picker row. Markdown, so headings and the code fence get highlighted.
---@param id string `:REVIEW_ID:`.
---@param entry { keyword: string, body: string, tag: string?, props: table<string, string> }
---@param root string Directory `:FILE:` is relative to.
---@param mark string Pre-check verdict: "changed", "UNCHANGED" or "?".
---@param context integer? Lines of code shown on each side of the anchor.
---@return string[]
function M.preview_lines(id, entry, root, mark, context)
  context = context or 5
  local props = entry.props
  local lnum = tonumber(props.LINE) or 1
  local end_lnum = tonumber(props.END_LINE) or lnum

  local lines = {
    string.format("%s · %s · %s · anchor %s", id, entry.tag or "QUESTION", entry.keyword or "?", mark),
    string.format("%s:%d", props.FILE or "?", lnum),
    "",
    "## Comment",
    entry.body or "",
  }
  local function section(title, value)
    if value and value ~= "" then
      vim.list_extend(lines, { "", "## " .. title, value })
    end
  end

  section("Proposed resolution", props.RESOLUTION)
  local meta = {}
  if props.CHANGE and props.CHANGE ~= "" then
    meta[#meta + 1] = "Change: " .. props.CHANGE
  end
  if props.RESOLVED_AT and props.RESOLVED_AT ~= "" then
    meta[#meta + 1] = "Resolved: " .. props.RESOLVED_AT
  end
  if #meta > 0 then
    vim.list_extend(lines, { "", table.concat(meta, "   ·   ") })
  end
  section("Reply", props.REPLY)

  vim.list_extend(lines, { "", "## Code at the anchor (now)" })
  local ok, file_lines = pcall(vim.fn.readfile, root .. "/" .. (props.FILE or ""))
  if not ok or type(file_lines) ~= "table" or #file_lines == 0 then
    lines[#lines + 1] = "(file unreadable)"
    return lines
  end
  local first = math.max(1, lnum - context)
  local last = math.min(#file_lines, end_lnum + context)
  local fmt = "%s %" .. #tostring(last) .. "d │ %s"
  lines[#lines + 1] = "```"
  for i = first, last do
    local marker = (i >= lnum and i <= end_lnum) and "▶" or " "
    lines[#lines + 1] = string.format(fmt, marker, i, file_lines[i])
  end
  lines[#lines + 1] = "```"
  return lines
end

--- Parse the subset of org this module emits: one heading per comment, each
--- followed by a property drawer. Not a general org parser -- anything else in
--- the file is skipped.
---@param path string
---@return table<string, { keyword: string, props: table<string, string> }>
function M.parse(path)
  local entries = {}
  local f = io.open(path, "r")
  if not f then
    return entries
  end

  local current
  for line in f:lines() do
    if line:match("^%*+%s") then
      local keyword, rest = line:match("^%*+%s+(%u+)%s+(.*)$")
      local tag, body = nil, rest or ""
      if rest then
        local stripped, found = rest:match("^(.-)%s*:(%u+):%s*$")
        if found then
          body, tag = stripped, found
        end
      end
      current = { keyword = keyword, body = body, tag = tag, props = {} }
    elseif current then
      local key, value = line:match("^%s*:([%u_]+):%s*(.-)%s*$")
      if key == "END" then
        if current.props.REVIEW_ID then
          entries[current.props.REVIEW_ID] = current
        end
        current = nil
      elseif key and key ~= "PROPERTIES" then
        current.props[key] = value
      end
    end
  end

  f:close()
  return entries
end

---@param props table<string, string>
---@param order string[]
---@param out string[]
local function emit_props(props, order, out)
  for _, key in ipairs(order) do
    local value = props[key]
    if value and value ~= "" then
      out[#out + 1] = string.format("  :%s:%s%s", key, string.rep(" ", math.max(1, 13 - #key)), value)
    end
  end
end

--- Render the quickfix review comments as org, carrying the agent's fields over
--- from `previous`.
---@param items table[] Review comments.
---@param previous table<string, { keyword: string, props: table<string, string> }>
---@param root string
---@return string
function M.render(items, previous, root)
  local now = os.date("[%Y-%m-%d %a %H:%M]")
  local out = {
    "#+TITLE: Review comments",
    M.TODO_LINE,
    "#+UPDATED: " .. now,
    "",
    "# Written by nvim. The agent owns the TODO keyword and the RESOLUTION,",
    "# CHANGE and RESOLVED_AT properties; REPLY is shared, last writer wins.",
    "# Every other field is nvim's and is overwritten on the next export.",
    "# Entries are matched by :REVIEW_ID:.",
    "",
  }

  for _, item in ipairs(items) do
    local file = item.filename or vim.api.nvim_buf_get_name(item.bufnr)
    local rel = relpath(file, root)
    local kind, body = split_type(item.text)
    local lnum = item.lnum or 1
    local end_lnum = item.end_lnum or lnum
    local id = review_id(rel, body)
    local prior = previous[id] or { props = {} }

    local props = {
      REVIEW_ID = id,
      FILE = rel,
      LINE = tostring(lnum),
      END_LINE = end_lnum ~= lnum and tostring(end_lnum) or nil,
      COL = item.col and item.col > 1 and tostring(item.col) or nil,
      END_COL = item.end_col and item.end_col > 0 and tostring(item.end_col) or nil,
    }
    for _, key in ipairs(WRITE_ONCE_PROPS) do
      props[key] = prior.props[key]
    end
    props.ANCHOR_HASH = props.ANCHOR_HASH or M.anchor_hash(file, lnum, end_lnum)
    props.CREATED = props.CREATED or now
    for _, key in ipairs(M.AGENT_PROPS) do
      props[key] = prior.props[key]
    end

    out[#out + 1] = string.format("* %s %s :%s:", prior.keyword or "TODO", body, kind)
    out[#out + 1] = "  :PROPERTIES:"
    emit_props(props, {
      "REVIEW_ID",
      "FILE",
      "LINE",
      "END_LINE",
      "COL",
      "END_COL",
      "ANCHOR_HASH",
      "CREATED",
      "RESOLUTION",
      "REPLY",
      "CHANGE",
      "RESOLVED_AT",
    }, out)
    out[#out + 1] = "  :END:"
    out[#out + 1] = ""
  end

  return table.concat(out, "\n")
end

--- Write `.review.org` from the current quickfix list, preserving whatever the
--- agent has written into it since the last export.
---
--- An emptied list removes the file, which is what makes "file absent" a usable
--- drain gate. The stale path is the right one to remove: re-resolving the root
--- from an empty list would point elsewhere and leave the old file behind.
---
--- `.nvim-state.org` goes with it. It exists only while a review is in
--- progress, and left beside a drained review it would offer an agent a
--- timestamped editor state with nothing to attach it to.
---@param stale_path string? Path last written to, removed when the list empties.
---@return string? path
function M.export(stale_path)
  local items = M.review_items()
  if #items == 0 then
    if stale_path then
      os.remove(stale_path)
      os.remove((stale_path:gsub("[^/]+$", M.STATE_FILE)))
    end
    return nil
  end

  local root = M.root()
  local path = root .. "/" .. M.REVIEW_FILE
  local content = M.render(items, M.parse(path), root)

  local f = io.open(path, "w")
  if not f then
    return nil
  end
  f:write(content, "\n")
  f:close()
  return path
end

--- Read `.review.org` back into quickfix items.
---
--- This is the only form of a review that survives a restart: the plugin's own
--- storage file records buffer numbers rather than paths, so it is meaningless
--- outside the session that wrote it. The keyword is shown in the quickfix text
--- so a proposed resolution is visible in the list.
---@return table[] items, table<string, { keyword: string, props: table<string, string> }> entries
function M.import()
  local root = M.root()
  local path = root .. "/" .. M.REVIEW_FILE
  local entries = M.parse(path)
  local items = {}

  for _, entry in pairs(entries) do
    local props = entry.props
    if props.FILE and entry.body then
      local lnum = tonumber(props.LINE) or 1
      local end_lnum = tonumber(props.END_LINE) or lnum
      local col = tonumber(props.COL) or 1
      local end_col = tonumber(props.END_COL)
      local kind = entry.tag or "QUESTION"
      -- A proposed resolution rides in the comment text so it shows up in the
      -- quickfix list and in the fzf picker, which read `text` and nothing else.
      local body = entry.body
      if entry.keyword and entry.keyword ~= "TODO" then
        body = string.format("%s → %s", body, entry.keyword)
      end
      items[#items + 1] = {
        filename = vim.fs.normalize(root .. "/" .. props.FILE),
        lnum = lnum,
        end_lnum = end_lnum,
        col = col,
        end_col = end_col,
        text = M.qf_text(kind, lnum, end_lnum, props.COL and col or nil, end_col, body),
        type = kind:sub(1, 1),
        user_data = { review_id = props.REVIEW_ID, keyword = entry.keyword },
      }
    end
  end

  table.sort(items, function(a, b)
    if a.filename ~= b.filename then
      return a.filename < b.filename
    end
    return a.lnum < b.lnum
  end)

  return items, entries
end

--- The `:REVIEW_ID:` a quickfix item would be exported under.
---
--- Derived from the item rather than read from `user_data`, which only exists
--- on comments that came back through `M.import` -- a comment added in this
--- session has none, and matching on it would silently miss exactly those.
---@param item table Quickfix item.
---@param root string?
---@return string
function M.item_id(item, root)
  root = root or M.root()
  local file = item.filename or vim.api.nvim_buf_get_name(item.bufnr)
  local _, body = split_type(item.text)
  return review_id(relpath(file, root), body)
end

--- Set one heading's keyword, and replace or add the properties given.
---
--- Scoped to the entry owning `id`: the heading line and everything up to its
--- `:END:`. A property already present is replaced in place rather than
--- appended, so a heading reopened twice carries one `:REPLY:`, not two.
---@param path string
---@param id string
---@param keyword string?
---@param props table<string, string>?
---@return boolean written
function M.annotate(path, id, keyword, props)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or type(lines) ~= "table" then
    return false
  end

  local heading, drawer_end
  local current
  for i, line in ipairs(lines) do
    if line:match("^%*+%s") then
      current = i
    elseif line:match("^%s*:REVIEW_ID:%s+" .. id .. "%s*$") then
      heading = current
    elseif heading and not drawer_end and line:match("^%s*:END:%s*$") then
      drawer_end = i
      break
    end
  end
  if not heading or not drawer_end then
    return false
  end

  if keyword then
    lines[heading] = lines[heading]:gsub("^(%*+%s+)%u+", "%1" .. keyword, 1)
  end

  for key, value in pairs(props or {}) do
    local rendered = string.format("  :%s:%s%s", key, string.rep(" ", math.max(1, 13 - #key)), value)
    local replaced = false
    for i = heading + 1, drawer_end - 1 do
      if lines[i]:match("^%s*:" .. key .. ":") then
        lines[i] = rendered
        replaced = true
        break
      end
    end
    if not replaced then
      table.insert(lines, drawer_end, rendered)
      drawer_end = drawer_end + 1
    end
  end

  vim.fn.writefile(lines, path)
  return true
end

--- Cap on how many rows of any one section reach `.nvim-state.org`. A LaTeX
--- build or a fresh LSP attach can produce thousands; the tail of such a list
--- carries no information the head does not.
local STATE_LIMIT = 200

local SEVERITY = { "ERROR", "WARN", "INFO", "HINT" }

--- Flatten to one line: a message with a newline in it would otherwise close
--- the heading and be read as body text, or as a new heading if it starts with
--- a star.
---@param s string
---@return string
local function one_line(s)
  return (tostring(s):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

---@param out string[]
---@param root string
local function emit_diagnostics(out, root)
  local all = vim.diagnostic.get()
  -- Sorted by severity, because STATE_LIMIT keeps the head of the list and an
  -- error is what the file is opened to find. `vim.diagnostic.get` returns
  -- buffer order, in which a project's hints can push every error past the cap.
  -- Ties break on position so the file does not churn between writes.
  table.sort(all, function(a, b)
    if a.severity ~= b.severity then
      return (a.severity or 4) < (b.severity or 4)
    end
    if a.bufnr ~= b.bufnr then
      return a.bufnr < b.bufnr
    end
    if a.lnum ~= b.lnum then
      return a.lnum < b.lnum
    end
    return a.col < b.col
  end)
  out[#out + 1] = string.format("* Diagnostics (%d)", #all)
  for i, d in ipairs(all) do
    if i > STATE_LIMIT then
      out[#out + 1] = string.format("** ... %d more", #all - STATE_LIMIT)
      break
    end
    local name = vim.api.nvim_buf_is_valid(d.bufnr) and vim.api.nvim_buf_get_name(d.bufnr) or ""
    local tag = d.source and (":" .. d.source:gsub("%W", "_") .. ":") or ""
    out[#out + 1] = string.format(
      "** %s %s:%d:%d %s %s",
      SEVERITY[d.severity] or "INFO",
      relpath(name, root),
      d.lnum + 1,
      d.col + 1,
      one_line(d.message),
      tag
    )
  end
end

---@param out string[]
---@param root string
local function emit_quickfix(out, root)
  local qf = vim.fn.getqflist({ all = 0 })
  local items = qf.items or {}
  out[#out + 1] = string.format("* Quickfix (%d)", #items)
  out[#out + 1] = "  :PROPERTIES:"
  out[#out + 1] = "  :TITLE:       " .. one_line(qf.title or "")
  out[#out + 1] = "  :END:"
  for i, item in ipairs(items) do
    if i > STATE_LIMIT then
      out[#out + 1] = string.format("** ... %d more", #items - STATE_LIMIT)
      break
    end
    local name = item.filename or (item.bufnr ~= 0 and vim.api.nvim_buf_get_name(item.bufnr)) or ""
    out[#out + 1] = string.format("** %s:%d %s", relpath(name, root), item.lnum or 0, one_line(item.text))
  end
end

---@param out string[]
---@param root string
local function emit_buffers(out, root)
  local rows = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.buflisted(bufnr) == 1 then
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name ~= "" then
        local tags = {}
        if vim.bo[bufnr].modified then
          tags[#tags + 1] = "modified"
        end
        if not vim.api.nvim_buf_is_loaded(bufnr) then
          tags[#tags + 1] = "unloaded"
        end
        if bufnr == vim.api.nvim_get_current_buf() then
          tags[#tags + 1] = "current"
        end
        rows[#rows + 1] = string.format(
          "** %s %s",
          relpath(name, root),
          #tags > 0 and (":" .. table.concat(tags, ":") .. ":") or ""
        )
      end
    end
  end
  out[#out + 1] = string.format("* Buffers (%d)", #rows)
  vim.list_extend(out, rows)
end

--- Write `.nvim-state.org`: LSP diagnostics, the quickfix list and the open
--- buffers, as the agent cannot see any of them from a shell.
---
--- Regenerated whole every time and never read back, so unlike `.review.org` it
--- needs no merge and has no second writer.
---@return string path
function M.write_state()
  local root = M.root()
  local path = root .. "/" .. M.STATE_FILE

  local out = {
    "#+TITLE: nvim state",
    "#+UPDATED: " .. os.date("[%Y-%m-%d %a %H:%M:%S]"),
    "",
    "# Written by nvim, read-only for the agent. Regenerated whole on every",
    "# update: nothing written here survives.",
    "",
  }
  emit_diagnostics(out, root)
  emit_quickfix(out, root)
  emit_buffers(out, root)

  local f = io.open(path, "w")
  if f then
    f:write(table.concat(out, "\n"), "\n")
    f:close()
  end
  return path
end

return M
