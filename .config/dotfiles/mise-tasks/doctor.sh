#!/bin/sh
set -eu

DEST_DIR="$HOME/.local/share/dotfiles"
HOOK_PATH="$DEST_DIR/hooks/pre-commit"
FAIL=0

print_status() {
  _title="$1"
  _status="$2"
  _detail="${3:-}"

  if [ "$_status" = "OK" ]; then
    if [ -n "$_detail" ]; then
      printf "  - %-30s ... OK (%s)\n" "$_title" "$_detail"
    else
      printf "  - %-30s ... OK\n" "$_title"
    fi
  else
    printf "  - %-30s ... FAIL\n" "$_title" >&2
    if [ -n "$_detail" ]; then
      echo "       Error: $_detail" >&2
    fi
    FAIL=1
  fi
}

echo "Running system diagnostics..."

# 1. Verify required system binaries
for tool in git mise uv prek; do
  if _path=$(command -v "$tool" 2> /dev/null); then
    print_status "Binary: $tool" "OK" "$_path"
  else
    print_status "Binary: $tool" "FAIL" "'$tool' not found on PATH"
  fi
done

# 2. Verify physical bare repo path existence
if [ -d "$DEST_DIR" ]; then
  print_status "Bare repository path" "OK" "$DEST_DIR"
else
  print_status "Bare repository path" "FAIL" "Directory missing at $DEST_DIR"
fi

# 3. Verify git catalog query response
if git --git-dir="$DEST_DIR" --work-tree="$HOME" status -q > /dev/null 2>&1; then
  print_status "Dotfiles status integrity" "OK" "Clean tree"
else
  print_status "Dotfiles status integrity" "FAIL" "Git status failed or contains unhandled merge conflicts"
fi

# 4. NEW: Verify untracked files behavior configuration
_untracked_cfg=$(git --git-dir="$DEST_DIR" --work-tree="$HOME" config status.showUntrackedFiles 2> /dev/null || echo "not set")
if [ "$_untracked_cfg" = "no" ]; then
  print_status "Git untracked optimization" "OK" "status.showUntrackedFiles=no"
else
  print_status "Git untracked optimization" "FAIL" "status.showUntrackedFiles is '$_untracked_cfg' (should be 'no')"
fi

# 5. Verify hook presence and active execute access bits
if [ -x "$HOOK_PATH" ]; then
  print_status "Pre-commit execution hooks" "OK" "Active & executable"

  # 6. NEW: Verify hook contains bare repo environment overrides
  _injection="export GIT_DIR=\"$DEST_DIR\" GIT_WORK_TREE=\"$HOME\""
  if grep -qF "$_injection" "$HOOK_PATH"; then
    print_status "Pre-commit environment patch" "OK" "Bare repo variables injected"
  else
    print_status "Pre-commit environment patch" "FAIL" "Hook exists but is missing GIT_DIR environment configuration"
  fi
elif [ -f "$HOOK_PATH" ]; then
  print_status "Pre-commit execution hooks" "FAIL" "File exists at $HOOK_PATH but is missing execute permissions (+x)"
else
  print_status "Pre-commit execution hooks" "FAIL" "Hook script missing entirely from $HOOK_PATH"
fi

# Final Summary Evaluation Block
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "✅ All diagnostic checks passed successfully."
else
  echo "❌ Some health verification steps failed. See errors above." >&2
  exit 1
fi
