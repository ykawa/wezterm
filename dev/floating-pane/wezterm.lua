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
    { key = 'LeftArrow', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
    { key = 'RightArrow', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
    { key = 'UpArrow', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
    { key = 'DownArrow', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
  },
}
