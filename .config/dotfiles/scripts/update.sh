#!/bin/sh
set -eu
DEST_DIR="$HOME/.local/share/dotfiles"

df() { git --git-dir="$DEST_DIR" --work-tree="$HOME" "$@"; }

BRANCH="$(df symbolic-ref --short HEAD 2> /dev/null || true)"
if [ -n "$BRANCH" ]; then
  echo "Pulling latest changes..."
  df pull origin "$BRANCH"
else
  echo "Warning: HEAD is detached; skipping pull." >&2
fi

echo "Syncing submodules..."
df submodule update --init
