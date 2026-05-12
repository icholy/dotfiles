local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font configuration (matching your Alacritty setup)
config.font_size = 13
config.line_height = 1.0
config.font_locator = "FontConfig"
config.bold_brightens_ansi_colors = "No"
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

config.font = wezterm.font("UbuntuMono Nerd Font", {
  weight = "Regular",
  italic = false,
})

config.font_rules = {
  {
    italic = false,
    intensity = "Bold",
    font = wezterm.font("UbuntuMono Nerd Font", { weight = "Bold", italic = false }),
  },
  {
    italic = true,
    intensity = "Normal",
    font = wezterm.font("UbuntuMono Nerd Font", { weight = "Regular", italic = true }),
  },
  {
    italic = true,
    intensity = "Bold",
    font = wezterm.font("UbuntuMono Nerd Font", { weight = "Bold", italic = true }),
  },
}

-- Color scheme (matching your Solarized Light theme)
config.colors = {
  foreground = '#657b83',
  background = '#fdf6e3',

  cursor_bg = '#657b83',
  cursor_fg = '#fdf6e3',
  cursor_border = '#657b83',

  selection_fg = '#657b83',
  selection_bg = '#eee8d5',

  scrollbar_thumb = '#839496',

  split = '#93a1a1',

  ansi = {
    '#073642', -- black (base02)
    '#dc322f', -- red
    '#859900', -- green
    '#b58900', -- yellow
    '#268bd2', -- blue
    '#d33682', -- magenta
    '#2aa198', -- cyan
    '#eee8d5', -- white (base2)
  },

  brights = {
    '#002b36', -- bright black (base03)
    '#cb4b16', -- bright red (orange)
    '#586e75', -- bright green (base01)
    '#657b83', -- bright yellow (base00)
    '#839496', -- bright blue (base0)
    '#6c71c4', -- bright magenta (violet)
    '#93a1a1', -- bright cyan (base1)
    '#fdf6e3', -- bright white (base3)
  },

  -- Tab bar colors (matching Solarized Light theme)
  tab_bar = {
    background = '#eee8d5', -- base2 (slightly darker than background)

    active_tab = {
      bg_color = '#fdf6e3', -- base3 (background color)
      fg_color = '#657b83', -- base00 (foreground color)
    },

    inactive_tab = {
      bg_color = '#eee8d5', -- base2
      fg_color = '#93a1a1', -- base1
    },

    inactive_tab_hover = {
      bg_color = '#93a1a1', -- base1
      fg_color = '#657b83', -- base00
    },

    new_tab = {
      bg_color = '#eee8d5', -- base2
      fg_color = '#93a1a1', -- base1
    },

    new_tab_hover = {
      bg_color = '#93a1a1', -- base1
      fg_color = '#657b83', -- base00
    },
  },
}

-- Key bindings (matching your Alacritty Ctrl+Shift+N for new instance)
config.keys = {
  {
    key = 'n',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SpawnWindow,
  },
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action.SendString '\x1b\r',
  },
}

-- Optional: Additional WezTerm specific settings that might be useful
config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Enable graphics protocol support (useful for image display in terminal)
config.enable_kitty_graphics = true

return config
