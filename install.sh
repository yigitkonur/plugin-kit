#!/bin/sh
# plugin-kit installer. One line on any machine:
#   curl -fsSL https://raw.githubusercontent.com/yigitkonur/plugin-kit/main/install.sh | sh
#   ... | sh -s -- --all     also: install every plugin globally (off) in Claude Code and Codex, and schedule the update job
# It clones this repo to ~/.local/share/plugin-kit (or updates it) and links `plugin` and the helpers into ~/.local/bin.
set -eu
KIT="${PLUGIN_KIT_HOME:-$HOME/.local/share/plugin-kit}"
BIN="${PLUGIN_BIN:-$HOME/.local/bin}"
command -v git >/dev/null 2>&1 || { echo "plugin-kit: git is required" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "plugin-kit: python3 (3.11+) is required" >&2; exit 1; }
mkdir -p "$BIN" "$(dirname "$KIT")"
if [ -d "$KIT/.git" ]; then git -C "$KIT" pull --ff-only -q; else git clone -q https://github.com/yigitkonur/plugin-kit.git "$KIT"; fi
for f in plugin plugin-here sp codex-plugin-project.sh; do ln -sf "$KIT/bin/$f" "$BIN/$f"; done
echo "plugin-kit: linked plugin, plugin-here, sp, codex-plugin-project.sh into $BIN"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "plugin-kit: add $BIN to PATH (export PATH=\"$BIN:\$PATH\")" ;; esac
if [ "${1:-}" = "--all" ]; then
  PATH="$BIN:$PATH"
  plugin install all
  plugin autoupdate install
  plugin doctor || true
fi
