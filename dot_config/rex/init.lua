-- Rex configuration: https://www.superlogical.com/rex/docs/customize/config
-- Reload after editing with `rex config reload`; check with `rex config check`.

-- ============================================================================
-- HELPERS
-- ============================================================================

local TERMINAL = "com.superlogical.terminal"
-- Absolute paths: actions run in the Rex server, whose PATH lacks Homebrew.
local FM = "/usr/bin/fm"
local scripts = os.getenv("HOME") .. "/.config/rex/scripts/"

-- The focused pane's directory: the shell's OSC 7 report, else the
-- foreground program's cwd (a pane running claude reports no pwd change).
local function pane_dir(block_id)
  local res = rex.block.call(TERMINAL, "pwd", { block_id = block_id })
  if res and res.pwd then
    return (res.pwd:gsub("^file://[^/]*", ""))
  end
  local proc = rex.block.call(TERMINAL, "process", { block_id = block_id })
  return proc and proc.foreground and proc.foreground.cwd or os.getenv("HOME")
end

-- The last n lines of a pane's screen, as plain text.
local function screen_tail(block_id, n)
  local screen = rex.block.call(TERMINAL, "format", {
    block_id = block_id, trim = true, unwrap = true,
  })
  if not screen or not screen.content then
    return ""
  end
  local lines = {}
  for line in screen.content:gmatch("[^\n]+") do
    lines[#lines + 1] = line
  end
  return table.concat(lines, "\n", math.max(1, #lines - n + 1))
end

local function foreground_program(block_id)
  local proc = rex.block.call(TERMINAL, "process", { block_id = block_id })
  local fg = proc and proc.foreground
  return fg and (fg.argv0 or fg.name) or "shell"
end

-- A block's leaf in a layout tree, with the split holding it and its side.
local function find_leaf(node, block_id, parent, side)
  if node.block_id == block_id then
    return node, parent, side
  end
  if node.split then
    local leaf, p, s = find_leaf(node.split.before, block_id, node.split, "before")
    if leaf then
      return leaf, p, s
    end
    return find_leaf(node.split.after, block_id, node.split, "after")
  end
end

local function first_leaf(node)
  return node.block_id and node or first_leaf(node.split.before)
end

-- Where a block sits: its window, layer, layout leaf, parent split and side.
local function locate(session_id, block_id)
  local view = rex.session.view{ session_id = session_id }
  for _, win in ipairs(view and view.windows or {}) do
    for _, layer in ipairs(win.layers or {}) do
      local leaf, parent, side = find_leaf(layer.layout, block_id)
      if leaf then
        return win, layer, leaf, parent, side
      end
    end
  end
end

local function popup(command, cwd, bounds)
  local _, err = rex.session.new_layer{
    bounds = bounds or { 0.1, 0.15, 0.8, 0.7 },
    focus  = true,
    layout = rex.layout.block{
      flavor  = TERMINAL .. ".shell",
      options = { command = command, cwd = cwd },
    },
  }
  if err then
    rex.log("error", "popup: " .. tostring(err))
  end
end

-- ============================================================================
-- PREFIX: Ctrl+A, then one key (same layout as the former zellij "tmux" mode)
-- ============================================================================

local P = "ctrl+a>"

-- Ctrl+A no longer reaches the terminal on its own; press it twice to send one
-- (readline's beginning-of-line).
rex.bind(P .. "ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- ----- Tabs -----
-- No 1-9 bindings: on AZERTY the digits need Shift, so they never matched.
-- t for tab, as in zellij's tab mode (Ctrl+t).
rex.bind(P .. "t", "client.tab.new")
rex.bind(P .. "q", "client.tab.close")
-- Panes live on the server: q, x and ctrl+q end them. These two only change
-- what this client shows, so remote sessions keep running.
rex.bind(P .. "d", "client.host.switch")
rex.bind(P .. "shift+d", "session.collapse")
-- Sessions only group tabs, so shift+tab walks the app's whole tab bar,
-- across sessions, in sidebar order. Tab is attention_next (below).
rex.bind(P .. "shift+tab", "client.tab.previous")

rex.bind(P .. ",", "client.tab.rename")

-- ----- Panes -----
rex.bind(P .. "v", "pane.split", { direction = "right" })
rex.bind(P .. "h", "pane.split", { direction = "down" })
rex.bind(P .. "m", "pane.zoom")
rex.bind(P .. "left", "pane.focus.left")
rex.bind(P .. "right", "pane.focus.right")
rex.bind(P .. "up", "pane.focus.up")
rex.bind(P .. "down", "pane.focus.down")

-- Zellij's CloseFocus: block.close on a tab's last pane also closes the tab.
-- It targets this block, where pane.close acts on whatever the app focuses.
rex.action{
  name     = "smart_close",
  title    = "Close Pane, or Tab if Last",
  category = "Panes",
  run      = function(ctx, args)
    local _, err = rex.call("block.close", {
      session_id = ctx.session_id, block_id = ctx.block_id,
    })
    if err then
      rex.log("error", "smart_close: " .. tostring(err))
    end
  end,
}
rex.bind(P .. "x", "smart_close")

-- Where each floated pane came from, so a second press puts it back there.
local floated = {}

rex.action{
  name     = "float_pane",
  title    = "Float or Re-embed Pane",
  category = "Panes",
  run      = function(ctx, args)
    local win, layer, leaf, parent, side = locate(ctx.session_id, ctx.block_id)
    if not win then
      return
    end
    local err
    if layer.kind == "floating" then
      local home = floated[ctx.block_id]
      local anchor = home and home.anchor
      local tiled
      for _, l in ipairs(win.layers) do
        if l.kind == "tiled" then
          tiled = l
        end
      end
      if not (anchor and tiled and find_leaf(tiled.layout, anchor)) then
        home, anchor = nil, tiled and first_leaf(tiled.layout).block_id
      end
      _, err = rex.session.move_block{
        session_id      = ctx.session_id,
        block_id        = ctx.block_id,
        anchor_block_id = anchor,
        direction       = home and home.direction or "horizontal",
        side            = home and home.side or "after",
        ratio           = home and home.ratio or 0.5,
      }
      floated[ctx.block_id] = nil
    elseif not parent then
      -- Floating a tab's only tiled pane leaves the layout without a root.
      return { error = "the tab's last tiled pane cannot float" }
    else
      local other = side == "before" and parent.after or parent.before
      floated[ctx.block_id] = {
        anchor    = first_leaf(other).block_id,
        direction = parent.direction,
        side      = side,
        ratio     = parent.ratio,
      }
      _, err = rex.session.float_block{
        session_id = ctx.session_id,
        block_id   = ctx.block_id,
        bounds     = { 0.1, 0.1, 0.8, 0.8 },
      }
    end
    if err then
      rex.log("error", "float_pane: " .. tostring(err))
    end
  end,
}
rex.bind(P .. "space", "float_pane")

-- Zellij's ToggleFloatingPanes. Hidden is app state the server view does not
-- show, so with floating panes present this asks the app to toggle them; with
-- none it opens a shell in the focused pane's directory. Popups (nvim from
-- Ctrl+A e, pane_info) are floating layers too, so f hides them as well.
local function floating_count(win)
  local n = 0
  for _, l in ipairs(win and win.layers or {}) do
    if l.kind == "floating" then
      n = n + 1
    end
  end
  return n
end

-- A floating shell in the focused pane's directory, focused. Each one sits
-- 0.03 lower-right of the last so none hides another; past 5 it wraps back.
local function open_floating(ctx, win, name)
  local shift = (floating_count(win) % 6) * 0.03
  local _, err = rex.session.new_layer{
    session_id = ctx.session_id,
    window_id  = win and win.window_id,
    bounds     = { 0.1 + shift, 0.1 + shift, 0.75, 0.75 },
    focus      = true,
    layout     = rex.layout.block{
      flavor  = TERMINAL .. ".shell",
      options = { cwd = pane_dir(ctx.block_id) },
    },
  }
  if err then
    rex.log("error", name .. ": " .. tostring(err))
  end
end

rex.action{
  name     = "toggle_floating",
  title    = "Open or Hide Floating Panes",
  category = "Panes",
  run      = function(ctx, args)
    local win = locate(ctx.session_id, ctx.block_id)
    if floating_count(win) > 0 then
      rex.client.queue("pane.minimize_all_floating", {})
    else
      open_floating(ctx, win, "toggle_floating")
    end
  end,
}
rex.bind(P .. "f", "toggle_floating")

rex.action{
  name     = "new_floating",
  title    = "New Floating Pane",
  category = "Panes",
  run      = function(ctx, args)
    open_floating(ctx, locate(ctx.session_id, ctx.block_id), "new_floating")
  end,
}
rex.bind(P .. "n", "new_floating")

rex.action{
  name     = "pane_info",
  title    = "Summarize Pane",
  category = "Panes",
  run      = function(ctx, args)
    local r = rex.exec({
      FM, "respond", "--no-stream",
      "--instructions", "In one line of at most 12 words, say what this terminal "
        .. "is doing and whether it needs the user (an error, a question, a "
        .. "finished job).",
      "program: " .. foreground_program(ctx.block_id)
        .. "\ndirectory: " .. pane_dir(ctx.block_id)
        .. "\n\n" .. screen_tail(ctx.block_id, 60),
    }, { env = { NO_COLOR = "1" }, timeout = 20 })
    local summary = r and r.ok and r.stdout:match("[^\n]*%S[^\n]*")
    if not summary then
      rex.log("error", "pane_info: " .. tostring(r and r.stderr))
      return
    end
    summary = summary:gsub("^%s+", ""):gsub("%s+$", "")
    -- A popup that paints its own background (layers are transparent);
    -- the pane's label stays Rex's. Any key closes it.
    popup({ "bash", "-c",
      'source "$1"; popup_paint; printf "\\n  %s\\n\\n  (any key)" "$2"; read -rsn1',
      "pane_info", scripts .. "popup.bash", summary,
    }, nil, { 0.2, 0.4, 0.6, 0.15 })
    return { summary = summary }
  end,
}
rex.bind(P .. "i", "pane_info")

-- ----- Sessions, search, palette -----
rex.bind(P .. "c", "session.new")

-- Sessions only group tabs, so s fuzzy-finds any tab by name. The sidebar's
-- tab filter (client.sidebar.filter.focus) would be the native choice, but
-- Enter does not open its top match yet; rebind s to it once it does.
-- Rex's own pickers take no custom items, so this floats an fzf popup that
-- asks the app whose key press ran it to show the pick.
-- A tab's name as the sidebar shows it: its own label when renamed, else its
-- focused pane's terminal title, else that pane's Rex label.
local function tab_name(session_id, win)
  if win.label and not win.label:match("^Window %x%x%x%x%x%x%x%x$") then
    return win.label
  end
  local f = win.focused_block_id
  -- Without session_id a block resolves only in the action's own session.
  local t = f and rex.block.call(TERMINAL, "title", {
    block_id = f, session_id = session_id,
  })
  if t and t.title and t.title ~= "" then
    return t.title
  end
  for _, layer in ipairs(win.layers or {}) do
    for _, b in ipairs(layer.blocks or {}) do
      if b.block_id == f and b.label then
        return b.label
      end
    end
  end
  return "-"
end

-- One "SESSION_ID<TAB>WINDOW_ID<TAB>name" line per tab, in sidebar order,
-- the current tab marked. Built in the server: one rex process per tab
-- made the popup take over half a second to fill.
local function tab_menu(current_window_id)
  local lines = {}
  -- An action's connection can only view the session it runs in; attach_all
  -- lets it view every session without joining any as a client.
  local list = rex.call("session.attach_all", { event_scope = "session" })
  for _, s in ipairs(list and list.sessions or {}) do
    local view = rex.session.view{ session_id = s.session_id }
    for _, w in ipairs(view and view.windows or {}) do
      local mark = w.window_id == current_window_id and "● " or "  "
      local name = tab_name(s.session_id, w):gsub("[\t\n]", " ")
      lines[#lines + 1] = s.session_id .. "\t" .. w.window_id .. "\t" .. mark .. name
    end
  end
  return lines
end

rex.action{
  name     = "tab_pick",
  title    = "Go to Tab by Name",
  category = "Tabs",
  run      = function(ctx, args)
    local win = locate(ctx.session_id, ctx.block_id)
    local lines = tab_menu(win and win.window_id)
    local path = os.tmpname()
    local file = assert(io.open(path, "w"))
    file:write(table.concat(lines, "\n"), "\n")
    file:close()
    local cmd = { scripts .. "tab-pick", "--popup", "--menu", path }
    if ctx.client_id then
      cmd[#cmd + 1] = "-C"
      cmd[#cmd + 1] = ctx.client_id
    end
    -- Tall enough for every tab plus prompt and border, capped at 60%.
    local h = math.min(0.6, 0.08 + 0.035 * #lines)
    popup(cmd, nil, { 0.3, 0.2, 0.4, h })
    return { tabs = #lines }
  end,
}
rex.bind(P .. "s", "tab_pick")

-- Ctrl+A Tab jumps to the tab that most needs the user, across sessions:
-- blocked, then error, then done and not yet seen, then done and seen.
-- Working and idle tabs are skipped; with none of the four, it is plain
-- client.tab.next. Within a rank the next tab after the current one in sidebar
-- order wins, so repeated presses rotate through that rank.
local RANK_BLOCKED, RANK_ERROR, RANK_UNSEEN, RANK_SEEN = 1, 2, 3, 4

-- Program status keeps "done" after the user looks, so seen is tracked here:
-- block_id -> updated_at of the done report last seen. A newer done report
-- makes the block unseen again. Lost on config reload or server restart.
local seen_done = {}

-- Seconds since the epoch for an RFC 3339 timestamp such as
-- 2026-11-11T19:28:51.123+01:00, or nil when it does not parse.
-- os.time reads its table as local time, so the UTC days are computed here.
local function rfc3339_epoch(s)
  local y, mo, d, h, mi, sec, tz = s:match(
    "^(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)[%.%d]*(.*)$")
  if not y then
    return nil
  end
  y, mo = tonumber(y), tonumber(mo)
  -- Days from 1970-01-01 to the date (Howard Hinnant's days_from_civil).
  y = mo <= 2 and y - 1 or y
  local era = math.floor(y / 400)
  local yoe = y - era * 400
  local doy = math.floor((153 * (mo + (mo > 2 and -3 or 9)) + 2) / 5) + d - 1
  local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
  local t = ((era * 146097 + doe - 719468) * 24 + h) * 3600 + mi * 60 + sec
  local sign, oh, om = tz:match("^([+-])(%d+):(%d+)$")
  if sign then
    local off = (tonumber(oh) * 60 + tonumber(om)) * 60
    t = sign == "+" and t - off or t + off
  end
  return t
end

-- Done reports from before this config loaded count as seen: the seen list
-- starts empty, and those results were most likely read in the app already.
local config_loaded_at = os.time()

local function done_seen(block_id, record)
  if seen_done[block_id] == record.updated_at then
    return true
  end
  local t = rfc3339_epoch(record.updated_at)
  return t ~= nil and t < config_loaded_at
end

-- A block's most urgent status record, or nil when it reports none.
local function block_status(session_id, block_id)
  local res = rex.block.call(TERMINAL, "program_status", {
    block_id = block_id, session_id = session_id,
  })
  local order = { blocked = 1, error = 2, done = 3 }
  local best
  for _, r in ipairs(res and res.records or {}) do
    local o = order[r.state]
    if o and (not best or o < order[best.state]
        or (o == order[best.state] and r.updated_at > best.updated_at)) then
      best = r
    end
  end
  return best
end

local function window_blocks(win)
  local ids = {}
  for _, layer in ipairs(win.layers or {}) do
    for _, b in ipairs(layer.blocks or {}) do
      ids[#ids + 1] = b.block_id
    end
  end
  return ids
end

local function mark_seen(session_id, win)
  for _, b in ipairs(window_blocks(win)) do
    local s = block_status(session_id, b)
    if s and s.state == "done" then
      seen_done[b] = s.updated_at
    end
  end
end

-- The tab's rank: the best of its blocks', or nil when none needs the user.
local function window_rank(session_id, win)
  local rank
  for _, b in ipairs(window_blocks(win)) do
    local s = block_status(session_id, b)
    local r = s and (s.state == "blocked" and RANK_BLOCKED
      or s.state == "error" and RANK_ERROR
      or (done_seen(b, s) and RANK_SEEN or RANK_UNSEEN))
    if r and (not rank or r < rank) then
      rank = r
    end
  end
  return rank
end

-- Only attention_next marks tabs seen: Rex 0.1 never calls rex.on handlers
-- from init.lua, so a tab opened by click is not seen. Once it does, mark
-- seen on active_window_changed.

rex.action{
  name     = "attention_next",
  title    = "Next Tab Needing Attention",
  category = "Tabs",
  run      = function(ctx, args)
    local current = locate(ctx.session_id, ctx.block_id)
    local current_id = current and current.window_id
    -- Every tab in sidebar order, and the current tab's position in it.
    local tabs, here = {}, 0
    local list = rex.call("session.attach_all", { event_scope = "session" })
    for _, s in ipairs(list and list.sessions or {}) do
      local view = rex.session.view{ session_id = s.session_id }
      for _, w in ipairs(view and view.windows or {}) do
        if w.window_id == current_id then
          -- The user is looking at it, so its done panes are seen.
          mark_seen(s.session_id, w)
          here = #tabs + 1
        end
        tabs[#tabs + 1] = { session_id = s.session_id, win = w }
      end
    end
    -- Scan from the tab after the current one, wrapping, so the first tab
    -- found at the best rank is the next one in sidebar order.
    local best, best_rank
    for i = 1, here > 0 and #tabs - 1 or #tabs do
      local t = tabs[(here + i - 1) % #tabs + 1]
      local r = window_rank(t.session_id, t.win)
      if r and (not best_rank or r < best_rank) then
        best, best_rank = t, r
      end
    end
    if not best then
      rex.client.queue("client.tab.next", {})
      return { rank = "none" }
    end
    mark_seen(best.session_id, best.win)
    rex.client.queue("session.select", {
      session_id = best.session_id, window_id = best.win.window_id,
    })
    return { rank = best_rank, window_id = best.win.window_id }
  end,
}
rex.bind(P .. "tab", "attention_next")

-- What attention_next sees, without switching: one entry per tab that needs
-- the user, in sidebar order, with its rank and each done pane's seen flag.
local RANK_NAMES = { "blocked", "error", "done unseen", "done seen" }
rex.action{
  name     = "attention_list",
  title    = "List Tabs Needing Attention",
  category = "Tabs",
  run      = function(ctx, args)
    local out = {}
    local list = rex.call("session.attach_all", { event_scope = "session" })
    for _, s in ipairs(list and list.sessions or {}) do
      local view = rex.session.view{ session_id = s.session_id }
      for _, w in ipairs(view and view.windows or {}) do
        local r = window_rank(s.session_id, w)
        if r then
          local panes = {}
          for _, b in ipairs(window_blocks(w)) do
            local st = block_status(s.session_id, b)
            if st then
              panes[#panes + 1] = {
                state = st.state, updated_at = st.updated_at,
                seen_at = seen_done[b],
                seen = st.state == "done" and done_seen(b, st) or nil,
              }
            end
          end
          out[#out + 1] = {
            tab = tab_name(s.session_id, w), window_id = w.window_id,
            rank = RANK_NAMES[r], panes = panes,
          }
        end
      end
    end
    return { tabs = out }
  end,
}
rex.bind(P .. "ctrl+s", "session.switch")
rex.bind(P .. "w", "session.open_on_web")
rex.bind(P .. "ctrl+q", "session.close")
rex.bind(P .. "b", "client.sidebar.toggle")
rex.bind(P .. "/", "client.find.open")
-- ; instead of zellij's ?: on AZERTY ? needs Shift and , is already rename.
rex.bind(P .. ";", "client.palette.toggle")

-- Rex rejects "$" as a key name; on a Mac AZERTY layout it is [BracketRight].
rex.bind(P .. "[BracketRight]", "session.rename")

-- ============================================================================
-- RESIZE MODE: Ctrl+A r, then arrows; Esc, q or Enter to leave
-- ============================================================================

-- Exclusive so stray keys don't reach the terminal while resizing.
rex.mode("resize", { exclusive = true })
rex.bind(P .. "r", "client.mode.enter", { name = "resize" })

rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/down", "pane.resize", { direction = "down" })
rex.bind("resize/=", "pane.balance")
rex.bind("resize/escape", "client.mode.exit")
rex.bind("resize/q", "client.mode.exit")
rex.bind("resize/enter", "client.mode.exit")

-- ============================================================================
-- EDIT SCROLLBACK: Ctrl+A e opens the focused pane's scrollback in nvim
-- ============================================================================

rex.action{
  name     = "edit_scrollback",
  title    = "Edit Scrollback in Neovim",
  category = "Terminal",
  run      = function(ctx, args)
    local screen, err = rex.block.call(TERMINAL, "format", {
      block_id = ctx.block_id,
      trim     = true,
      unwrap   = true,
    })
    if not screen then
      rex.log("error", "edit_scrollback: " .. tostring(err))
      return
    end

    local path = os.tmpname()
    local file = assert(io.open(path, "w"))
    file:write(screen.content)
    file:close()

    -- Over the pane at its exact size, like zellij's EditScrollback; the
    -- layer closes when nvim exits.
    local win, layer, leaf = locate(ctx.session_id, ctx.block_id)
    local _, lerr = rex.session.new_layer{
      session_id = ctx.session_id,
      window_id  = win and win.window_id,
      bounds     = leaf and leaf.rect or { 0, 0, 1, 1 },
      focus      = true,
      layout     = rex.layout.block{
        flavor  = TERMINAL .. ".shell",
        options = { command = { "nvim", "+", path } },
      },
    }
    if lerr then
      rex.log("error", "edit_scrollback: " .. tostring(lerr))
    end
  end,
}
rex.bind(P .. "e", "edit_scrollback")

-- ============================================================================
-- AGENTS: new_agent (command palette) starts an agent in a new jj workspace,
-- Ctrl+A g lists them
-- ============================================================================

-- Rex's Lua API has no text prompt, so new_agent floats a short-lived
-- terminal over the current window, palette-style, running a script that asks
-- with fzf. It closes when the script exits. No key: it is rarely used.
rex.action{
  name     = "new_agent",
  title    = "New Agent in jj Workspace",
  category = "Agents",
  run      = function(ctx, args)
    local dir = pane_dir(ctx.block_id)
    popup({ scripts .. "agent-new", "--popup", "-r", dir }, dir)
  end,
}

-- The Activity sidebar is Rex's own agent list: state per pane, click to jump.
-- Ctrl+A b toggles the sidebar on whichever panel it last showed; this always
-- opens Activity.
rex.bind(P .. "g", "client.sidebar.activity.toggle")

-- ============================================================================
-- TERMINAL
-- ============================================================================

rex.bind("cmd+k", "com.superlogical.terminal.clear")

-- ============================================================================
-- AZERTY OPTION CHARACTERS
-- ============================================================================

-- With Option sent as Alt, the macOS AZERTY Option chords no longer type their
-- characters; these give them back. An action, not a function binding: direct
-- function bindings load but do not dispatch.
rex.action{
  name     = "type_text",
  title    = "Type Text",
  category = "Terminal",
  args     = { text = "string" },
  run      = function(ctx, args)
    local _, err = rex.block.call(TERMINAL, "write", {
      block_id = ctx.block_id,
      data     = args.text,
    })
    if err then
      rex.log("error", "type_text: " .. tostring(err))
    end
  end,
}

-- Physical keys: Rex's parser rejects ( ) : as key names. On a Mac AZERTY
-- layout, ( = Digit5, ) = Minus, : = Period, = = Slash.
rex.bind("alt+[KeyN]", "type_text", { text = "~" })
-- Shift+letter bindings load but never dispatch in Rex 0.1.0, so | also has
-- Option+= until that is fixed.
rex.bind("shift+alt+[KeyL]", "type_text", { text = "|" })
rex.bind("alt+[Slash]", "type_text", { text = "|" })
rex.bind("shift+alt+[Period]", "type_text", { text = "\\" })
rex.bind("shift+alt+[Digit5]", "type_text", { text = "[" })
rex.bind("shift+alt+[Minus]", "type_text", { text = "]" })
rex.bind("alt+[Digit5]", "type_text", { text = "{" })
rex.bind("alt+[Minus]", "type_text", { text = "}" })
