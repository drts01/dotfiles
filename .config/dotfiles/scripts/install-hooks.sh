#!/bin/sh
set -eu
BASEDIR="${BASEDIR:-$(cd "$(dirname "$0")/.." && pwd)}"
DEST_DIR="$HOME/.local/share/dotfiles"
HOOK_PATH="$DEST_DIR/hooks/pre-commit"

echo "Initializing git hooks..."
if ! command -v prek > /dev/null 2>&1; then
  echo "Warning: 'prek' not found. Skipping git hooks installation." >&2
  exit 0
fi

prek install --config "$BASEDIR/prek.toml" --git-dir "$DEST_DIR"

INJECTION="export GIT_DIR=\"$DEST_DIR\" GIT_WORK_TREE=\"$HOME\""
if grep -qF "$INJECTION" "$HOOK_PATH"; then
  echo "Pre-commit hook already patched."
else
  echo "Patching prek pre-commit hook..."
  TMP_HOOK="$HOOK_PATH.tmp"
  awk -v injection="$INJECTION" 'NR==2{print injection}1' "$HOOK_PATH" > "$TMP_HOOK"
  chmod +x "$TMP_HOOK"
  mv "$TMP_HOOK" "$HOOK_PATH"
fi
