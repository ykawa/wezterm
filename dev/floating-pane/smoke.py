#!/usr/bin/env python3
"""Run inside the development GUI; validate its CLI and pane lifecycle."""
import json
import os
from pathlib import Path
import subprocess
import sys
import time


def cli(*args):
    return subprocess.check_output(["wezterm", "cli", *args], text=True)


def panes():
    return json.loads(cli("list", "--format", "json"))


def wait_for(predicate):
    deadline = time.monotonic() + 15
    while time.monotonic() < deadline:
        if predicate():
            return
        time.sleep(0.2)
    raise AssertionError("Timed out waiting for pane state")


def run():
    root = int(os.environ["WEZTERM_PANE"])
    floating = []
    for _ in range(3):
        floating.append(int(cli("spawn", "--pane-id", str(root),
                                "--floating-pane", "--", "sleep", "60")))
    state = panes()
    assert all(any(p["pane_id"] == pane and p["is_floating"] for p in state)
               for pane in floating)
    # Remove a non-active pane, followed by the active and remaining panes.
    for pane in (floating[1], floating[2], floating[0]):
        cli("kill-pane", "--pane-id", str(pane))
        wait_for(lambda: all(p["pane_id"] != pane for p in panes()))
    assert any(p["pane_id"] == root and not p["is_floating"] for p in panes())
    git_pane = int(cli("spawn", "--pane-id", str(root), "--floating-pane",
                       "--cwd", os.getcwd(), "--", "lazygit"))
    wait_for(lambda: "Commits" in cli("get-text", "--pane-id", str(git_pane)))
    subprocess.run(["wezterm", "cli", "send-text", "--pane-id", str(git_pane),
                    "--no-paste", "q"], check=True)
    wait_for(lambda: all(p["pane_id"] != git_pane for p in panes()))
    assert any(p["pane_id"] == root and p["is_active"] for p in panes())
    # Exercise the actual Helix key binding, rather than just the raw CLI.
    demo = Path(__file__).resolve().parent
    helix_pane = int(cli("spawn", "--pane-id", str(root), "--cwd", os.getcwd(),
                         "--", "helix", "--config", str(demo / "helix.toml"),
                         "README.md"))
    wait_for(lambda: "README.md" in cli("get-text", "--pane-id", str(helix_pane)))
    subprocess.run(["wezterm", "cli", "send-text", "--pane-id", str(helix_pane),
                    "--no-paste", " ,g"], check=True)
    wait_for(lambda: any(p["is_floating"] for p in panes()))
    helix_float = next(p["pane_id"] for p in panes() if p["is_floating"])
    wait_for(lambda: "Commits" in cli("get-text", "--pane-id", str(helix_float)))
    subprocess.run(["wezterm", "cli", "send-text", "--pane-id", str(helix_float),
                    "--no-paste", "q"], check=True)
    wait_for(lambda: all(p["pane_id"] != helix_float for p in panes()))
    assert any(p["pane_id"] == helix_pane and p["is_active"] for p in panes())
    subprocess.run(["wezterm", "cli", "send-text", "--pane-id", str(helix_pane),
                    "--no-paste", ":quit!\r"], check=True)
    wait_for(lambda: all(p["pane_id"] != helix_pane for p in panes()))
    return {"result": "passed", "root_pane": root,
            "checks": ["spawn three floating panes", "close non-active pane",
                       "close active and last panes", "render lazygit terminal output",
                       "quit lazygit and restore root pane",
                       "Helix Space-comma-g opens floating lazygit",
                       "quit lazygit and return to Helix"]}


if __name__ == "__main__":
    try:
        result = run()
    except Exception as error:
        result = {"result": "failed", "error": repr(error)}
    Path(sys.argv[1]).write_text(json.dumps(result, indent=2) + "\n")
    sys.exit(result["result"] != "passed")
