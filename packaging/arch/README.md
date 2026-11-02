# Arch Linux package

`wezterm-floating` packages the floating-pane fork as a replacement for stock
WezTerm. The PKGBUILD pins the application source to commit
`1566bfc224202193d815ad7acc5821d436e070bc`.

## Install on another PC

Use an up-to-date x86-64 Arch Linux or compatible system. Download the
`wezterm-floating-*.pkg.tar.zst` package and `SHA256SUMS` from this fork's
GitHub Release into the same directory, then run:

```sh
sha256sum --check --ignore-missing SHA256SUMS
sudo pacman -U ./wezterm-floating-20261103.4.g1566bfc22-1-x86_64.pkg.tar.zst
```

Accept replacement of an existing WezTerm package. This package provides
`wezterm` and conflicts with the stock, git, bin, and nightly-bin packages.
It includes the CLI, GUI, mux server, desktop entry, icons, completions,
and shell integration. Terminfo is supplied by Arch's `ncurses` package to
avoid owning the same file twice.

Close and reopen WezTerm to switch to the new GUI. A running stock GUI or mux
server keeps its old code until restarted; save work and end its sessions
yourself before doing so. The fork's mux codec is incompatible with stock
WezTerm, so use matching builds at both ends of a mux connection.

Verify the running binaries:

```sh
wezterm --version
wezterm cli spawn --help
```

The spawn help should include `--floating-pane`. Existing configuration is
retained; floating-pane settings are opt-in. For example:

```lua
config.keys = {
  { key = 'h', mods = 'CTRL|ALT', action = wezterm.action.MoveFloatingPane { 'Left', 5 } },
  { key = 'j', mods = 'CTRL|ALT', action = wezterm.action.MoveFloatingPane { 'Down', 5 } },
  { key = 'k', mods = 'CTRL|ALT', action = wezterm.action.MoveFloatingPane { 'Up', 5 } },
  { key = 'l', mods = 'CTRL|ALT', action = wezterm.action.MoveFloatingPane { 'Right', 5 } },
  { key = 'LeftArrow', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
  { key = 'RightArrow', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
  { key = 'DownArrow', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
  {
    key = 'p', mods = 'CTRL|SHIFT',
    action = wezterm.action.ToggleFloatingPane,
  },
}
```

Merge these entries into an existing key table rather than replacing other keys.
While a floating pane is visible, Left/Up shrink and Right/Down expand it.
Each pane retains its size across hiding and mux reconnects. Window size bounds
are enforced without discarding the requested size. When a tiled pane is active,
these shortcuts continue to resize normal splits. Ctrl+Alt+H/J/K/L moves the visible floating pane left/down/up/right by five
cells. Movement stops at the terminal area edges and preserves the terminal
size. Each pane retains its position through hiding and mux reconnects.
Window or pane resizing clamps its display position temporarily; a later move
starts from the displayed position and only updates that axis.
Mouse drag resizing or movement is not implemented.

This release uses mux codec 49. Fully restart old GUI and mux-server processes
after saving session work; codec 48 (and older) processes cannot connect to this version.
You can also open a floating shell from inside the fork's GUI:

```sh
wezterm cli spawn --floating-pane
```

## Rebuild

For portable distribution, build in regular Arch Linux instead of inheriting
host-specific settings such as `-march=native`:

```sh
./packaging/arch/build-in-docker.sh
```

The package appears in `packaging/arch/out/`. This requires Docker and space
for the Rust build. The script runs `makepkg` as an unprivileged container user
and installs build dependencies only inside the container.

For a local source build, install `base-devel`, then run as a normal user:

```sh
cd packaging/arch
makepkg -si
```

The pinned Git source includes recursive submodules. `makepkg` runs targeted
release-mode mux and client regression tests before packaging.

Arch is rolling release: shared library ABI changes may require rebuilding.
An x86-64 package cannot be installed on an ARM PC. Release assets are updated
manually; installing this package does not configure automatic fork updates.

## Return to the previous package

Keep the previous package file, and install it with `sudo pacman -U` to replace
this fork. Switching package files does not restart or terminate open sessions.

On the initial development PC, the installed nightly version was saved as:

```sh
sudo pacman -U ~/.local/share/wezterm-floating/rollback/wezterm-nightly-bin-20261024-1-x86_64.pkg.tar.xz
```

## Multiple floating panes

All floating panes remain visible while floating mode is shown. The focused
pane is painted in front; use Alt+Left/Right or click an exposed pane to focus
it. Newly created panes start centered and may cover earlier panes until moved
with `MoveFloatingPane`. ToggleFloatingPane hides or shows the group. Only the
focused pane displays the IME preedit text and active cursor. Closing a focused
floating pane with `exit` or Ctrl+D focuses a remaining floating pane and keeps
the group visible; closing the last one returns focus to the tiled pane.
