#!/bin/sh
set -eu
DEST_DIR="$HOME/.local/share/dotfiles"

df() { git --git-dir="$DEST_DIR" --work-tree="$HOME" "$@"; }

# Check if we are on a branch or in a detached HEAD state cleanly
if df symbol-ref -q HEAD > /dev/null; then
  BRANCH="$(df symbolic-ref --short HEAD)"
  echo "Pulling latest changes on branch '$BRANCH'..."
  df pull origin "$BRANCH"
else
  echo "Warning: HEAD is detached; skipping pull." >&2
fi

echo "Syncing submodules..."
df submodule update --init --recursive
