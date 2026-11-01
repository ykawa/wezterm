#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
output_dir=${1:-"$script_dir/out"}
mkdir -p -- "$output_dir"
output_dir=$(cd -- "$output_dir" && pwd)

# Build against regular Arch libraries and generic x86-64 compiler settings,
# rather than inheriting CachyOS or host-specific CPU optimizations.
docker run --rm \
  -e BUILD_UID="$(id -u)" -e BUILD_GID="$(id -g)" \
  -v "$script_dir:/packaging:ro" -v "$output_dir:/output" \
  archlinux:base-devel bash -euc '
    pacman -Syu --noconfirm --needed \
      git rust cmake python pkgconf fontconfig freetype2 libpng zlib \
      libx11 libxcb libxkbcommon libxkbcommon-x11 xcb-util \
      xcb-util-image xcb-util-keysyms xcb-util-wm wayland openssl \
      libssh2 libgit2 ncurses hicolor-icon-theme ttf-dejavu
    groupadd -g "$BUILD_GID" builder
    useradd -m -u "$BUILD_UID" -g builder builder
    install -d -o builder -g builder /build
    cp /packaging/PKGBUILD /build/PKGBUILD
    chown builder:builder /build/PKGBUILD
    runuser -u builder -- bash -euc "cd /build && makepkg --noconfirm"
    find /build -maxdepth 1 -name "*.pkg.tar.zst" -exec cp {} /output/ \;
    chown "$BUILD_UID:$BUILD_GID" /output/*.pkg.tar.zst
  '
