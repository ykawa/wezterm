local wezterm = require 'wezterm'

return {
  initial_cols = 120,
  initial_rows = 36,
  window_background_opacity = 1.0,
  floating_pane_padding = {
    left = '10%', right = '10%', top = '10%', bottom = '10%',
  },
  keys = {
    {
      key = 'g', mods = 'CTRL|SHIFT',
      action = wezterm.action.SpawnCommandInNewFloatingPane { args = { 'lazygit' } },
    },
    { key = 'p', mods = 'CTRL|SHIFT', action = wezterm.action.ToggleFloatingPane },
  },
}
