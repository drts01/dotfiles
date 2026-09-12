#!/bin/sh
set -eu

BASEDIR="${MISE_PROJECT_ROOT:-$(pwd)}"
DEST_DIR="$HOME/.local/share/dotfiles"
HOOK_PATH="$DEST_DIR/hooks/pre-commit"

echo "Checking pre-commit hooks execution environment..."
if ! command -v prek > /dev/null 2>&1; then
  echo "Warning: 'prek' not found. Skipping git hooks installation." >&2
  exit 0
fi

prek install --config "$BASEDIR/prek.toml" --git-dir "$DEST_DIR"

if [ ! -f "$HOOK_PATH" ]; then
  echo "ERROR: Hook file was not generated at $HOOK_PATH" >&2
  exit 1
fi

INJECTION="export GIT_DIR=\"$DEST_DIR\" GIT_WORK_TREE=\"$HOME\""

# Safely check if the hook already contains our bare repo configuration overrides
if grep -qF "$INJECTION" "$HOOK_PATH"; then
  echo "Pre-commit hook already properly patched for a bare repo environment."
else
  echo "Patching prek pre-commit hook..."
  TMP_HOOK="$HOOK_PATH.tmp"
  # Inject the bare repo variables cleanly right under the shebang line (line 2)
  awk -v injection="$INJECTION" 'NR==2{print injection}1' "$HOOK_PATH" > "$TMP_HOOK"
  chmod +x "$TMP_HOOK"
  mv "$TMP_HOOK" "$HOOK_PATH"
  echo "Patch successfully applied."
fi
