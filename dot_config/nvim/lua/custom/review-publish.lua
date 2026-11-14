--- Publish the local review comments as one GitHub pull-request review.
---
--- GitHub anchors an inline comment to a line of the PR's head commit on the
--- RIGHT side, and rejects (HTTP 422) one whose line is not inside a diff
--- hunk. Comments are line numbers of the new version of a file, which is what
--- the difftastic right pane records, so a comment that falls inside a hunk is
--- sent inline and any other is listed in the review body instead.
local org = require("custom.review-org")

local M = {}

M.EVENTS = { "pending", "comment", "approve", "request_changes" }

--- Right-side line ranges of a unified-diff patch.
---@param patch string? GitHub's per-file `patch`; absent for binary files.
---@return integer[][] ranges `{ first, last }` pairs of new-file lines.
function M.hunks(patch)
  local ranges = {}
  for first, count in (patch or ""):gmatch("@@ %-%d+,?%d* %+(%d+),?(%d*) @@") do
    local n = count == "" and 1 or tonumber(count)
    if n > 0 then
      ranges[#ranges + 1] = { tonumber(first), tonumber(first) + n - 1 }
    end
  end
  return ranges
end

--- Whether one hunk holds the whole of `lo..hi`; a comment range spanning two
--- hunks is rejected by GitHub.
---@param ranges integer[][]
---@param lo integer
---@param hi integer
---@return boolean
function M.in_hunk(ranges, lo, hi)
  for _, r in ipairs(ranges) do
    if lo >= r[1] and hi <= r[2] then
      return true
    end
  end
  return false
end

---@param text string Quickfix text, `[TYPE...] body`.
---@return string kind, string body
local function split_text(text)
  return text:match("^%[(%u+)") or "QUESTION", (text:gsub("^%[[^%]]*%]%s*", ""))
end

--- Sort review items into inline comments and body-only leftovers.
---@param items table[] Quickfix review items.
---@param root string Workspace root the paths are made relative to.
---@param files table<string, integer[][]> Hunk ranges by path, from the PR.
---@return table[] inline, table[] rest
function M.split(items, root, files)
  local inline, rest = {}, {}
  for _, item in ipairs(items) do
    local path = org.relpath(vim.api.nvim_buf_get_name(item.bufnr), root)
    local kind, body = split_text(item.text)
    local lo, hi = item.lnum, math.max(item.lnum, item.end_lnum or item.lnum)
    local entry = { path = path, lo = lo, hi = hi, kind = kind, body = body }
    if files[path] and M.in_hunk(files[path], lo, hi) then
      inline[#inline + 1] = entry
    else
      rest[#rest + 1] = entry
    end
  end
  return inline, rest
end

---@param inline table[]
---@param rest table[]
---@param sha string PR head commit.
---@param event string? One of `M.EVENTS`; `pending` or nil leaves the review unsubmitted.
---@return table
function M.payload(inline, rest, sha, event)
  local comments = {}
  for _, c in ipairs(inline) do
    local comment = { path = c.path, line = c.hi, side = "RIGHT", body = string.format("**%s** %s", c.kind, c.body) }
    if c.lo ~= c.hi then
      comment.start_line, comment.start_side = c.lo, "RIGHT"
    end
    comments[#comments + 1] = comment
  end

  local lines = {}
  for _, c in ipairs(rest) do
    local where = c.lo == c.hi and c.lo or (c.lo .. "-" .. c.hi)
    lines[#lines + 1] = string.format("- `%s:%s` **%s** %s", c.path, where, c.kind, c.body)
  end

  local payload = { commit_id = sha, comments = comments }
  if #lines > 0 then
    payload.body = "Comments outside the diff:\n\n" .. table.concat(lines, "\n")
  end
  if event and event ~= "pending" then
    payload.event = event:upper()
    -- GitHub rejects a COMMENT or REQUEST_CHANGES review that has no body.
    payload.body = payload.body or "Review comments from nvim."
  end
  return payload
end

---@param args string[]
---@param root string
---@param stdin string?
---@return string? stdout, string? err
local function gh(args, root, stdin)
  local res = vim.system(vim.list_extend({ "gh" }, args), { text = true, cwd = root, stdin = stdin }):wait()
  if res.code ~= 0 then
    return nil, vim.trim(res.stderr ~= "" and res.stderr or res.stdout)
  end
  return res.stdout, nil
end

--- Register `:ReviewPublish [PR] [EVENT]`.
---
--- The PR defaults to `$REVIEW_PR` (set by `review pr N`), then to the PR of
--- the current branch. Without an EVENT the review stays pending on GitHub.
--- A published comment leaves the local list, since the GitHub review is its
--- record from then on.
---@param after_change fun() Rewrites `.review.org` from the quickfix list.
function M.setup(after_change)
  vim.api.nvim_create_user_command("ReviewPublish", function(cmd)
    local root = org.root()
    local pr, event
    for _, arg in ipairs(cmd.fargs) do
      if tonumber(arg) then
        pr = arg
      else
        event = arg
      end
    end
    event = event or "pending"
    if not vim.tbl_contains(M.EVENTS, event) then
      vim.notify("ReviewPublish: event must be one of " .. table.concat(M.EVENTS, ", "), vim.log.levels.ERROR)
      return
    end

    local items = org.review_items()
    if #items == 0 then
      vim.notify("ReviewPublish: no review comments", vim.log.levels.WARN)
      return
    end

    pr = pr or vim.env.REVIEW_PR
    local view = { "pr", "view" }
    if pr then
      view[#view + 1] = pr
    end
    vim.list_extend(view, { "--json", "number,headRefOid" })
    local meta, err = gh(view, root)
    if not meta then
      vim.notify("ReviewPublish: " .. err, vim.log.levels.ERROR)
      return
    end
    local info = vim.json.decode(meta)

    local pages, files_err = gh(
      { "api", "--paginate", "--slurp", ("repos/{owner}/{repo}/pulls/%d/files"):format(info.number) },
      root
    )
    if not pages then
      vim.notify("ReviewPublish: " .. files_err, vim.log.levels.ERROR)
      return
    end
    local files = {}
    for _, page in ipairs(vim.json.decode(pages)) do
      for _, f in ipairs(page) do
        files[f.filename] = M.hunks(f.patch)
      end
    end

    local inline, rest = M.split(items, root, files)
    local prompt = string.format(
      "PR #%d (%s): send %d inline + %d in the body as %s?\nPublished comments leave the local list.",
      info.number,
      info.headRefOid:sub(1, 8),
      #inline,
      #rest,
      event
    )
    if vim.fn.confirm(prompt, "&Send\n&Cancel", 2) ~= 1 then
      return
    end

    local payload = M.payload(inline, rest, info.headRefOid, event)
    local _, post_err = gh(
      { "api", "-X", "POST", ("repos/{owner}/{repo}/pulls/%d/reviews"):format(info.number), "--input", "-" },
      root,
      vim.json.encode(payload)
    )
    if post_err then
      vim.notify("ReviewPublish: " .. post_err, vim.log.levels.ERROR)
      return
    end

    vim.fn.setqflist(
      vim.tbl_filter(function(item)
        return not org.is_review_comment(item)
      end, vim.fn.getqflist()),
      "r"
    )
    after_change()
    vim.notify(("Review sent to PR #%d (%s)"):format(info.number, event))
  end, {
    nargs = "*",
    complete = function()
      return M.EVENTS
    end,
    desc = "Review: publish comments as a GitHub PR review",
  })
end

return M
