-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}
local act = wezterm.action
local mux = wezterm.mux

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

config.leader = {
  key = 'a',
  mods = 'CTRL',
  timeout_milliseconds = 2000,
}
config.keys = {
  {
    key = '[',
    mods = 'LEADER',
    action = act.ActivateCopyMode,
  },
  {
    key = 'c',
    mods = 'LEADER',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'Tab',
    mods = 'LEADER',
    action = act.ActivateTabRelative(1),
  },
  {
    key = 'Tab',
    mods = 'LEADER|SHIFT',
    action = act.ActivateTabRelative(-1),
  },
  {
    key = 'P',
    mods = 'LEADER|SHIFT',
    action = act.ShowTabNavigator,
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = wezterm.action.ShowLauncher,
  },
  {
    key = '&',
    mods = 'LEADER',
    action = act.CloseCurrentTab { confirm = true },
  },
  {
    key = 'x',
    mods = 'LEADER',
    action = act.CloseCurrentPane { confirm = true },
  },
  {
    -- |
    key = 'v',
    mods = 'LEADER',
    action = act.SplitPane {
      direction = 'Right',
      size = { Percent = 50 },
    },
  },
  {
    -- -
    key = 's',
    mods = 'LEADER',
    action = act.SplitPane {
      direction = 'Down',
      size = { Percent = 50 },
    },
  },
  {
    key = 'z',
    mods = 'LEADER',
    action = act.TogglePaneZoomState,
  },
  {
    key = 'o',
    mods = 'LEADER',
    action = act.RotatePanes 'Clockwise',
  },
  {
    key = 'w',
    mods = 'LEADER',
    action = act.PaneSelect {
      mode = 'SwapWithActive',
    },
  },
  {
    key = 'LeftArrow',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'DownArrow',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 'UpArrow',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'd',
    mods = 'LEADER',
    action = act.DetachDomain 'CurrentPaneDomain',
  },
  {
    key = 'm',
    mods = 'LEADER',
    action = wezterm.action.PaneSelect,
  },
}

config.mouse_bindings = {
  -- Open URLs with CMD+Click
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

config.audible_bell = 'Disabled'
config.color_scheme = 'Gruvbox Material (Gogh)'
config.colors = { tab_bar = { active_tab = { fg_color = '#073642', bg_color = '#2aa198' } } }
config.enable_kitty_keyboard = true
config.enable_scroll_bar = true
config.font = wezterm.font 'Fira Code'
config.font_size = 14.
config.force_reverse_video_cursor = true
config.hide_tab_bar_if_only_one_tab = true
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.native_macos_fullscreen_mode = true
config.pane_focus_follows_mouse = true
config.scrollback_lines = 5000
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_bar_at_bottom = true
config.term = 'wezterm'
config.use_dead_keys = true
config.use_fancy_tab_bar = false
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
-- and finally, return the configuration to wezterm
--
wezterm.on('gui-startup', function()
  local tab, pane, window = mux.spawn_window {}
  window:gui_window():maximize()
end)
return config
