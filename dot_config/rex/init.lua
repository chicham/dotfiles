-- Rex configuration: https://www.superlogical.com/rex/docs/customize/config
-- Reload after editing with `rex config reload`; check with `rex config check`.

-- ============================================================================
-- PREFIX: Ctrl+A, then one key (same layout as the former zellij "tmux" mode)
-- ============================================================================

local P = "ctrl+a>"

-- Ctrl+A no longer reaches the terminal on its own; press it twice to send one
-- (readline's beginning-of-line).
rex.bind(P .. "ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- ----- Tabs -----
rex.bind(P .. "c", "client.tab.new")
rex.bind(P .. "q", "client.tab.close")
rex.bind(P .. ",", "client.tab.rename")
rex.bind(P .. "tab", "client.tab.next")
rex.bind(P .. "shift+tab", "client.tab.previous")
-- Rex has no tab picker like session.switch; jump by position instead (tabs count from 1).
for i = 1, 9 do
  rex.bind(P .. tostring(i), "client.tab.goto", { index = i })
end

-- ----- Panes -----
rex.bind(P .. "v", "pane.split", { direction = "right" })
rex.bind(P .. "h", "pane.split", { direction = "down" })
rex.bind(P .. "x", "pane.close")
rex.bind(P .. "m", "pane.zoom")
rex.bind(P .. "left", "pane.focus.left")
rex.bind(P .. "right", "pane.focus.right")
rex.bind(P .. "up", "pane.focus.up")
rex.bind(P .. "down", "pane.focus.down")

-- ----- Sessions, search, agents -----
rex.bind(P .. "shift+s", "session.switch")
rex.bind(P .. "s", "session.new")
rex.bind(P .. "b", "client.sidebar.toggle")
rex.bind(P .. "/", "client.find.open")

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
    local screen, err = rex.block.call("com.superlogical.terminal", "format", {
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

    -- A new tab, like zellij's EditScrollback; closes when nvim exits.
    rex.session.new_window{
      layout = rex.layout.block{
        flavor  = "com.superlogical.terminal.shell",
        options = { command = { "nvim", "+", path } },
      },
    }
  end,
}
rex.bind(P .. "e", "edit_scrollback")

-- ============================================================================
-- AGENTS: Ctrl+A n starts an agent in a new jj workspace, Ctrl+A g lists them
-- ============================================================================

-- Rex's Lua API has no text prompt, so new_agent floats a short-lived
-- terminal over the current window, palette-style, running a script that asks
-- with fzf. It closes when the script exits.
local scripts = os.getenv("HOME") .. "/.config/rex/scripts/"

-- The focused pane's directory: the shell's OSC 7 report, else the
-- foreground program's cwd (a pane running claude reports no pwd change).
local function pane_dir(block_id)
  local res = rex.block.call("com.superlogical.terminal", "pwd", { block_id = block_id })
  if res and res.pwd then
    return (res.pwd:gsub("^file://[^/]*", ""))
  end
  local proc = rex.block.call("com.superlogical.terminal", "process", { block_id = block_id })
  return proc and proc.foreground and proc.foreground.cwd or os.getenv("HOME")
end

local function popup(command, cwd)
  local _, err = rex.session.new_layer{
    bounds = { 0.1, 0.15, 0.8, 0.7 },
    focus  = true,
    layout = rex.layout.block{
      flavor  = "com.superlogical.terminal.shell",
      options = { command = command, cwd = cwd },
    },
  }
  if err then
    rex.log("error", "popup: " .. tostring(err))
  end
end

rex.action{
  name     = "new_agent",
  title    = "New Agent in jj Workspace",
  category = "Agents",
  run      = function(ctx, args)
    local dir = pane_dir(ctx.block_id)
    popup({ scripts .. "agent-new", "--popup", "-r", dir }, dir)
  end,
}
rex.bind(P .. "n", "new_agent")

-- The Activity sidebar is Rex's own agent list: state per pane, click to jump.
-- Ctrl+A b toggles the sidebar on whichever panel it last showed; this always
-- opens Activity.
rex.bind(P .. "g", "client.sidebar.activity.toggle")

-- ============================================================================
-- TERMINAL
-- ============================================================================

rex.bind("cmd+k", "com.superlogical.terminal.clear")
