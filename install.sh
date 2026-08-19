#!/usr/bin/env bash
# Pose un lien symbolique dans ~/.local/bin — un LIEN, pas une copie : une copie se met à
# diverger du dépôt dès la première correction, et c'est le dépôt qui doit rester la source.
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.local/bin"
ln -sf "$REPO/live-output" "$HOME/.local/bin/live-output"
echo "✔ ~/.local/bin/live-output → $REPO/live-output"
"$HOME/.local/bin/live-output" --help >/dev/null 2>&1 || true
