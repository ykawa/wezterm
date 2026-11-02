# Floating pane development fork

This branch ports Eric Nelson's floating pane implementation from
[WezTerm PR #5576](https://github.com/wezterm/wezterm/pull/5576)
to upstream main at `e68a8ec27727fbbda15e07f0a0737cd5e16481f6`.
The original implementation belongs to Eric Nelson (e82eric).

## Build and try

```sh
git submodule update --init --recursive
cargo build -p wezterm -p wezterm-gui -j 8
cargo test -p mux tab::test -- --test-threads=1
./dev/floating-pane/launch.sh README.md
```

The launcher starts a separate GUI process with a dedicated configuration and
puts this build's CLI first on PATH. Existing system binaries and user settings
are not replaced. Run the launcher from the project directory you want to edit.

In Helix, press **Space**, **,**, **g** to open lazygit as a floating pane.
Press **q** in lazygit to close it. **Ctrl+Shift+P** hides or shows the floating
pane; **Ctrl+Shift+G** opens another lazygit pane from any terminal pane.

**Ctrl+Alt+Shift+arrow** resizes the active floating pane by five cells:
Left/Up shrink its width/height, and Right/Down expand them. Each floating
pane keeps its own size while hidden and across mux reconnects. Window resize
clamps the display to available cells and restores the requested size when
space becomes available. The same action retains normal split-pane behavior
when a tiled pane is active. Mouse drag resizing is not implemented.

**Ctrl+Alt+H/J/K/L** moves the floating pane left/down/up/right by five cells,
without resizing its terminal. Movement stops at the tab's edges. Each pane
retains its own position across hiding and mux reconnects. A new pane starts
centered; once moved, its requested left/top coordinates are retained and
temporarily clamped when window or pane resizing leaves less room. A move
starts from the displayed position and only updates the selected axis.

From a shell inside this development GUI:

```sh
wezterm cli spawn --floating-pane --cwd "$PWD" -- lazygit
wezterm cli list --format json
```

The JSON list includes `is_floating`. The floating pane CLI must connect to this
fork's GUI, rather than the stock GUI: its mux codec version is 49, reflecting
the added messages and changed pane-tree format.

## Port changes

- Resolve conflicts with upstream configuration fields, confirmation actions,
  and mux codec changes.
- Preserve the current HarfBuzz submodule revision.
- Fix pruning of multiple floating panes: delete in reverse index order and
  preserve removals after the active pane.
- Cover pane removal and selection with a regression test.

## Validation on CachyOS / Wayland

- `cargo check -p wezterm -p wezterm-gui -j 8`: passed.
- `cargo build -p wezterm -p wezterm-gui -j 8`: passed.
- `cargo test -p mux tab::test -- --test-threads=1`: 3 passed.
- `smoke.py`, running inside a separate development GUI: passed CLI spawning,
  closing non-active/active/last floating panes, lazygit terminal output and
  exit, and the actual Helix Space-comma-g binding followed by return to Helix.

To repeat the GUI integration check from the repository root:

```sh
env -u WEZTERM_UNIX_SOCKET -u WEZTERM_PANE \
  PATH="$PWD/target/debug:$PATH" \
  target/debug/wezterm-gui --config-file dev/floating-pane/wezterm.lua \
  start --always-new-process --no-auto-connect \
  --class org.wezfurlong.wezterm.floating-test --cwd "$PWD" \
  -- python dev/floating-pane/smoke.py /tmp/wezterm-floating-smoke.json
cat /tmp/wezterm-floating-smoke.json
```

This is an experimental development build. Remote mux interoperability, all
rendering backends, and cross-platform behavior need further validation.

## Multiple floating panes

All floating panes remain visible while floating mode is shown. The focused
pane is painted in front; use Alt+Left/Right or click an exposed pane to focus
it. Newly created panes start centered and may cover earlier panes until moved
with `MoveFloatingPane`. ToggleFloatingPane hides or shows the group. Only the
focused pane displays the IME preedit text and active cursor. Closing a focused
floating pane with `exit` or Ctrl+D focuses a remaining floating pane and keeps
the group visible; closing the last one returns focus to the tiled pane.
