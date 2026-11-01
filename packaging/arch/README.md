# Arch Linux package

`wezterm-floating` packages the floating-pane fork as a replacement for stock
WezTerm. The PKGBUILD pins the merged application source to commit
`1fa582798f7e7508f5f92a7f00e40eeff5a2c96c`.

## Install on another PC

Use an up-to-date x86-64 Arch Linux or compatible system. Download the
`wezterm-floating-*.pkg.tar.zst` package and `SHA256SUMS` from this fork's
GitHub Release into the same directory, then run:

```sh
sha256sum --check --ignore-missing SHA256SUMS
sudo pacman -U ./wezterm-floating-20261102.1fa582798-1-x86_64.pkg.tar.zst
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
  {
    key = 'p', mods = 'CTRL|SHIFT',
    action = wezterm.action.ToggleFloatingPane,
  },
}
```

Merge this entry into an existing key table rather than replacing other keys.
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
