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
rex.bind(P .. "s", "session.switch")
rex.bind(P .. "/", "client.find.open")
-- The Activity sidebar lists every agent that is working, waiting, or done.
rex.bind(P .. "a", "client.sidebar.activity.toggle")

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
-- TERMINAL
-- ============================================================================

rex.bind("cmd+k", "com.superlogical.terminal.clear")
