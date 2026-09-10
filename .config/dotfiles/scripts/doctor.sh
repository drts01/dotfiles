#!/bin/sh
set -eu
BASEDIR="${BASEDIR:-$(cd "$(dirname "$0")/.." && pwd)}"
DEST_DIR="$HOME/.local/share/dotfiles"
HOOK_PATH="$DEST_DIR/hooks/pre-commit"
FAIL=0

check() {
  if command -v "$1" > /dev/null 2>&1; then
    echo "OK   $1 ($(command -v "$1"))"
  else
    echo "FAIL $1 not found on PATH" >&2
    FAIL=1
  fi
}

echo "Checking required tools..."
check git
check mise
check uv
check prek

echo "Checking bare repo..."
if [ -d "$DEST_DIR" ]; then
  echo "OK   bare repo present at $DEST_DIR"
else
  echo "FAIL bare repo missing at $DEST_DIR" >&2
  FAIL=1
fi

echo "Checking dotfiles status..."
if git --git-dir="$DEST_DIR" --work-tree="$HOME" status > /dev/null 2>&1; then
  echo "OK   dotfiles status clean"
else
  echo "FAIL 'dotfiles status' failed" >&2
  FAIL=1
fi

echo "Checking pre-commit hook..."
if [ -x "$HOOK_PATH" ]; then
  echo "OK   pre-commit hook installed and executable"
else
  echo "FAIL pre-commit hook missing or not executable at $HOOK_PATH" >&2
  FAIL=1
fi

echo "Checking uvfile.txt tools..."
while read -r line || [ -n "$line" ]; do
  case "$line" in '' | \#*) continue ;; esac
  # shellcheck disable=SC2086 # intentional word-splitting: "tool [--with pkgs...]"
  set -- $line
  tool=$1
  if uv tool list 2> /dev/null | grep -q "^$tool "; then
    echo "OK   uv tool '$tool' installed"
  else
    echo "FAIL uv tool '$tool' not installed" >&2
    FAIL=1
  fi
done < "$BASEDIR/uvfile.txt"

if [ "$FAIL" -eq 0 ]; then
  echo "All checks passed."
else
  echo "Some checks failed." >&2
  exit 1
fi
