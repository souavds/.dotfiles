local wezterm = require('wezterm')

local config = wezterm.config_builder()

-- system
config.enable_wayland = false

-- window
config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = false

-- color
config.color_scheme = 'GruvboxDark'

-- font
config.font = wezterm.font_with_fallback({
  'MonaspiceKr Nerd Font',
  { family = 'JetBrainsMono Nerd Font', scale = 1 }
})
config.font_size = 11.5

-- keybindings
-- config.leader = { key = '/', mod = 'CMD' }

return config
