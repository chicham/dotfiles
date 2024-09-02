-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Gruvbox Material (Gogh)'
config.hide_tab_bar_if_only_one_tab = true
config.force_reverse_video_cursor = true
config.enable_kitty_keyboard = true
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.font_size = 14.

-- and finally, return the configuration to wezterm
return config
