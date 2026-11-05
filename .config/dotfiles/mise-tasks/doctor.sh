#!/bin/sh
set -eu

DEST_DIR="${DEST_DIR:-$HOME/.local/share/dotfiles}"
HOOK_PATH="$DEST_DIR/hooks/pre-commit"
TROUBLESHOOT_URL=https://drts01.github.io/dotfiles/docs/how-to/troubleshooting/
FAIL=0
WARN=0

print_status() {
  _title="$1"
  _status="$2"
  _detail="${3:-}"
  _anchor="${4:-}"

  case "$_status" in
    OK) printf '  - %-30s ... OK%s\n' "$_title" "${_detail:+ ($_detail)}" ;;
    WARN)
      printf '  - %-30s ... WARN%s\n' "$_title" "${_detail:+ ($_detail)}"
      WARN=1
      ;;
    FAIL)
      printf '  - %-30s ... FAIL%s\n' "$_title" "${_detail:+ ($_detail)}" >&2
      if [ -n "$_anchor" ]; then
        printf '    see %s#%s\n' "$TROUBLESHOOT_URL" "$_anchor" >&2
      fi
      FAIL=1
      ;;
  esac
}

echo "Running system diagnostics..."

echo "Required installation checks:"
if _git=$(command -v git 2> /dev/null); then
  print_status "Binary: git" OK "$_git"
else
  print_status "Binary: git" FAIL "git is required" doctor-git-missing
fi

if [ -d "$DEST_DIR" ]; then
  print_status "Bare repository path" OK "$DEST_DIR"
else
  print_status "Bare repository path" FAIL "missing: $DEST_DIR" doctor-repo-missing
fi

if [ -n "${_git:-}" ] && [ -d "$DEST_DIR" ]; then
  if [ "$(git --git-dir="$DEST_DIR" rev-parse --is-bare-repository 2> /dev/null || :)" = true ]; then
    print_status "Bare repository integrity" OK
    _untracked_cfg=$(git --git-dir="$DEST_DIR" config --get status.showUntrackedFiles 2> /dev/null || :)
    if [ "$_untracked_cfg" = no ]; then
      print_status "Git untracked optimization" OK "status.showUntrackedFiles=no"
    else
      print_status "Git untracked optimization" FAIL "set status.showUntrackedFiles=no (current: ${_untracked_cfg:-unset})" doctor-untracked-setting
    fi

    echo "Working-tree status:"
    if _changes=$(git --git-dir="$DEST_DIR" --work-tree="$HOME" status --porcelain --untracked-files=no 2> /dev/null); then
      if [ -z "$_changes" ]; then
        print_status "Tracked files" OK "clean"
      else
        print_status "Tracked files" WARN "changes present; run dotfiles status"
      fi
    else
      print_status "Tracked files" FAIL "git status failed" doctor-status-failed
    fi
  else
    print_status "Bare repository integrity" FAIL "not a usable bare Git repository" doctor-repo-not-bare
  fi
fi

echo "Optional tooling and hooks:"
if _mise=$(command -v mise 2> /dev/null); then
  print_status "Binary: mise" OK "$_mise"
else
  print_status "Binary: mise" WARN "not installed; dotfiles still work"
fi
if _prek=$(command -v prek 2> /dev/null); then
  print_status "Binary: prek" OK "$_prek"
else
  print_status "Binary: prek" WARN "not installed; git hooks unavailable"
fi

if [ -x "$HOOK_PATH" ]; then
  print_status "Pre-commit hook" OK "executable"
  _injection="export GIT_DIR=\"$DEST_DIR\" GIT_WORK_TREE=\"$HOME\""
  if grep -qF "$_injection" "$HOOK_PATH"; then
    print_status "Bare-repo hook configuration" OK
  else
    print_status "Bare-repo hook configuration" FAIL "hook missing GIT_DIR/GIT_WORK_TREE overrides" doctor-hook-missing-override
  fi
elif [ -e "$HOOK_PATH" ] || [ -L "$HOOK_PATH" ]; then
  print_status "Pre-commit hook" FAIL "present but not executable" doctor-hook-not-executable
else
  print_status "Pre-commit hook" WARN "not installed; commits run without prek"
fi

printf '\n'
if [ "$FAIL" -ne 0 ]; then
  echo "Installation checks failed. See errors above." >&2
  exit 1
elif [ "$WARN" -ne 0 ]; then
  echo "Installation checks passed with warnings."
else
  echo "All installation checks passed."
fi
