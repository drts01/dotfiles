#!/bin/sh
# Exercise the OS /bin/sh, including its login profile and interactive $ENV file.
set -eu

CDPATH=
ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-posix-shell-test.XXXXXX")
trap 'rm -rf "$TMP"' EXIT
trap 'exit 1' HUP INT TERM

HOME_DIR="$TMP/home"
mkdir -p "$HOME_DIR/.config" "$HOME_DIR/.local/share" "$HOME_DIR/.local/state" "$HOME_DIR/.cache"
ln -s "$ROOT/.profile" "$HOME_DIR/.profile"
ln -s "$ROOT/.config/sh" "$HOME_DIR/.config/sh"

for file in \
  "$ROOT/.profile" \
  "$ROOT/.config/sh/.shrc" \
  "$ROOT"/.config/sh/profile.d/*.sh \
  "$ROOT"/.config/sh/sh.d/*.sh; do
  /bin/sh -n "$file"
done

# -l is supported by the /bin/sh implementations in the CI matrix; unlike
# sourcing .profile manually, it verifies the OS shell actually loads it.
env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=dumb /bin/sh -l -c '
  fail() { printf "FAIL: /bin/sh login: %s\n" "$*" >&2; exit 1; }
  [ "$XDG_CONFIG_HOME" = "$HOME/.config" ] || fail "XDG_CONFIG_HOME"
  [ "$XDG_DATA_HOME" = "$HOME/.local/share" ] || fail "XDG_DATA_HOME"
  [ "$ENV" = "$HOME/.config/sh/.shrc" ] || fail "ENV"
  case ${BASH_VERSION-} in
    ?*) [ "$_shell" = bash ] || fail "Bash invoked as sh" ;;
    *) [ "$_shell" = sh ] || fail "shell detection" ;;
  esac
  has sh || fail "has()"
  [ -n "$EDITOR" ] || fail "editor"
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

# A non-login interactive sh must load the shared configuration via $ENV.
env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=dumb \
  XDG_CONFIG_HOME="$HOME_DIR/.config" XDG_DATA_HOME="$HOME_DIR/.local/share" \
  XDG_STATE_HOME="$HOME_DIR/.local/state" XDG_CACHE_HOME="$HOME_DIR/.cache" \
  ENV="$HOME_DIR/.config/sh/.shrc" /bin/sh -ic '
  fail() { printf "FAIL: /bin/sh interactive: %s\n" "$*" >&2; exit 1; }
  case ${BASH_VERSION-} in
    ?*) [ "$_shell" = bash ] || fail "Bash invoked as sh" ;;
    *) [ "$_shell" = sh ] || fail "shell detection" ;;
  esac
  alias dotfiles > /dev/null || fail "dotfiles alias"
  has sh || fail "has()"
  has command-that-does-not-exist && fail "has() false positive"
  path_add "$HOME/interactive-path"
  case "$PATH" in "$HOME/interactive-path:"*) : ;; *) fail "path_add()" ;; esac
'

/bin/sh "$ROOT/.config/dotfiles/tests/source-cache.sh" "$ROOT" "$TMP/cache-test"
printf '/bin/sh startup and cache tests: ok\n'
