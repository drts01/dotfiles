#!/bin/sh
# Share one tracked ignore list between a development clone and the bare install.
set -eu

CDPATH=
BASEDIR=$(cd -- "$(dirname -- "$0")/.." && pwd)
IGNORE_FILE="$BASEDIR/gitignore"
GIT_DIR="${1:-$(git -C "$BASEDIR" rev-parse --absolute-git-dir)}"
EXCLUDE_FILE="$GIT_DIR/info/exclude"
BACKUP_FILE="$EXCLUDE_FILE.before-dotfiles"

if [ ! -f "$IGNORE_FILE" ]; then
  echo "ERROR: Missing tracked ignore list: $IGNORE_FILE" >&2
  exit 1
fi

if [ -L "$EXCLUDE_FILE" ]; then
  if [ "$(readlink "$EXCLUDE_FILE")" = "$IGNORE_FILE" ]; then
    exit 0
  fi
  echo "Warning: $EXCLUDE_FILE is already a symlink; leaving it unchanged." >&2
  exit 0
fi

if [ -e "$EXCLUDE_FILE" ]; then
  if [ ! -f "$EXCLUDE_FILE" ] || grep -Eq '^[[:space:]]*[^#[:space:]]' "$EXCLUDE_FILE"; then
    echo "Warning: $EXCLUDE_FILE contains local rules; leaving it unchanged." >&2
    exit 0
  fi
  if [ -e "$BACKUP_FILE" ] || [ -L "$BACKUP_FILE" ]; then
    echo "Warning: $BACKUP_FILE already exists; leaving $EXCLUDE_FILE unchanged." >&2
    exit 0
  fi
  # Git initializes this file with comments only; retain it for reference.
  mv "$EXCLUDE_FILE" "$BACKUP_FILE"
fi

mkdir -p "$GIT_DIR/info"
ln -s "$IGNORE_FILE" "$EXCLUDE_FILE"
