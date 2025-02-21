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

config.disable_default_key_bindings = true

config.keys = {
  {
    key = 'c',
    mods = 'SUPER',
    action = act.CopyTo 'Clipboard',
  },
  {
    key = 'v',
    mods = 'SUPER',
    action = act.PasteFrom 'Clipboard',
  },
  {
    key = 'Insert',
    mods = 'CTRL',
    action = act.CopyTo 'PrimarySelection',
  },
  {
    key = 'Insert',
    mods = 'CTRL',
    action = act.PasteFrom 'PrimarySelection',
  },
  {
    key = 't',
    mods = 'LEADER',
    action = act.ToggleFullScreen,
  },
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
    key = 'r',
    mods = 'LEADER',
    action = act.ReloadConfiguration,
  },
  {
    key = 'P',
    mods = 'LEADER|SHIFT',
    action = act.ShowTabNavigator,
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = act.ShowLauncher,
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = act.ClearScrollback 'ScrollbackOnly',
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
    key = 'h',
    mods = 'LEADER',
    action = act.SplitPane {
      direction = 'Down',
      size = { Percent = 50 },
    },
  },
  {
    key = 'm',
    mods = 'LEADER',
    action = act.TogglePaneZoomState,
  },
  {
    key = 'o',
    mods = 'LEADER',
    action = act.RotatePanes 'Clockwise',
  },
  {
    key = 's',
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
    key = 'w',
    mods = 'LEADER',
    action = act.PaneSelect,
  },
  {
    key = 'f',
    mods = 'LEADER',
    action = act.Search 'CurrentSelectionOrEmptyString',
  },
  {
    key = '&',
    mods = 'LEADER',
    action = act.CloseCurrentTab { confirm = true },
  },
}

config.mouse_bindings = {
  -- Open URLs with CMD+Click
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = act.OpenLinkAtMouseCursor,
  },
}
-- Set coloring for inactive panes to be less bright than your active pane
config.inactive_pane_hsb = {
  hue = 1,
  saturation = 0.8,
  brightness = 0.8,
}

config.audible_bell = 'Disabled'
config.color_scheme = 'Gruvbox Material (Gogh)'
config.colors = { tab_bar = { active_tab = { fg_color = '#073642', bg_color = '#2aa198' } } }
config.enable_kitty_keyboard = true
config.enable_scroll_bar = true
config.font = wezterm.font_with_fallback { 'FiraCode Nerd Font', 'Fira Code' }
config.font_size = 14.
config.force_reverse_video_cursor = true
config.hide_tab_bar_if_only_one_tab = true
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.native_macos_fullscreen_mode = true
config.pane_focus_follows_mouse = false
config.scrollback_lines = 5000
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_bar_at_bottom = true
config.scroll_to_bottom_on_input = true
config.show_new_tab_button_in_tab_bar = false
config.term = 'wezterm'
config.use_dead_keys = true
config.use_fancy_tab_bar = false
config.window_padding = { left = 0, right = 0, top = 0, bottom = '.5cell' }
-- and finally, return the configuration to wezterm
--
wezterm.on('gui-startup', function()
  local tab, pane, window = mux.spawn_window {}
  window:gui_window():maximize()
end)

config.mux_env_remove = {
  'SSH_AUTH_SOCK',
  'SSH_CLIENT',
}
config.prefer_to_spawn_tabs = true

local SSH_AUTH_SOCK = os.getenv 'SSH_AUTH_SOCK'

config.hide_mouse_cursor_when_typing = true

return config
