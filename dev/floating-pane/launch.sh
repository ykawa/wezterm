#!/usr/bin/env bash
set -euo pipefail

demo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$demo_dir/../.." && pwd)
export PATH="$repo_dir/target/debug:$PATH"

if [[ ! -x "$repo_dir/target/debug/wezterm-gui" ]]; then
  printf 'Build first: cargo build -p wezterm -p wezterm-gui\n' >&2
  exit 1
fi

exec "$repo_dir/target/debug/wezterm-gui" \
  --config-file "$demo_dir/wezterm.lua" \
  start --always-new-process --no-auto-connect \
  --class org.wezfurlong.wezterm.floating-dev \
  -- helix --config "$demo_dir/helix.toml" "$@"
