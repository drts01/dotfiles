#!/bin/sh
# Exercise Bash without requiring Zsh or initialized submodules.
set -eu

CDPATH=
ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-bash-shell-test.XXXXXX")
trap 'rm -rf "$TMP"' EXIT
trap 'exit 1' HUP INT TERM

BASH=$(command -v bash) || {
  printf 'FAIL: bash is required\n' >&2
  exit 1
}
HOME_DIR="$TMP/home"
mkdir -p "$HOME_DIR/.config" "$HOME_DIR/.local/share" "$HOME_DIR/.local/state" "$HOME_DIR/.cache"
ln -s "$ROOT/.profile" "$HOME_DIR/.profile"
ln -s "$ROOT/.bash_profile" "$HOME_DIR/.bash_profile"
ln -s "$ROOT/.bashrc" "$HOME_DIR/.bashrc"
ln -s "$ROOT/.config/sh" "$HOME_DIR/.config/sh"

for file in \
  "$ROOT/.profile" \
  "$ROOT/.bash_profile" \
  "$ROOT/.bashrc" \
  "$ROOT/.config/sh/.shrc" \
  "$ROOT"/.config/sh/profile.d/*.sh \
  "$ROOT"/.config/sh/sh.d/*.sh; do
  "$BASH" -n "$file"
done

# Run the same assertions through both Bash startup paths: .bash_profile
# for login shells and .bashrc for non-login interactive shells.
CHECK='
  fail() { printf "FAIL: bash %s: %s\n" "$BASH_TEST_MODE" "$*" >&2; exit 1; }
  case $BASH_TEST_MODE in
    login) shopt -q login_shell || fail "not a login shell" ;;
    interactive) if shopt -q login_shell; then fail "unexpected login shell"; fi ;;
  esac
  [ "${_shell-}" = bash ] || fail "shell detection"
  [ "${XDG_CONFIG_HOME-}" = "$HOME/.config" ] || fail "profile not loaded"
  [ "${ENV-}" = "$HOME/.config/sh/.shrc" ] || fail "ENV"
  [ "${HISTSIZE-}" = 20000 ] || fail "HISTSIZE"
  [ "${HISTFILESIZE-}" = 20000 ] || fail "HISTFILESIZE"
  [ "${HISTFILE-}" = "$HOME/.local/state/.bash_history" ] || fail "HISTFILE"
  [ "${HISTCONTROL-}" = ignoredups:erasedups ] || fail "HISTCONTROL"
  shopt -q cmdhist histappend || fail "history options"
  [ -n "${EDITOR-}" ] || fail "editor"
  alias dotfiles > /dev/null || fail "dotfiles alias"
  has bash || fail "has()"
  if has command-that-does-not-exist; then fail "has() false positive"; fi
  case ":$PATH:" in
    *":$HOME/.local/share/mise/shims:"*) : ;;
    *) fail "mise shims missing from PATH" ;;
  esac
  path_add "$HOME/test-path"
  case "$PATH" in "$HOME/test-path:"*) : ;; *) fail "path_add()" ;; esac
  before=$PATH
  path_add "$HOME/test-path"
  [ "$PATH" = "$before" ] || fail "path_add() duplicated a directory"
'

env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=dumb HOMEBREW_PREFIX=/nonexistent \
  BASH_TEST_MODE=login "$BASH" -lic "$CHECK"
env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=dumb HOMEBREW_PREFIX=/nonexistent \
  BASH_TEST_MODE=interactive "$BASH" --noprofile --rcfile "$HOME_DIR/.bashrc" -ic "$CHECK"
"$BASH" "$ROOT/.config/dotfiles/tests/source-cache.sh" "$ROOT" "$TMP/cache-test"
printf 'bash startup and cache tests: ok\n'
