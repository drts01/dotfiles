#!/bin/sh
set -eu

CDPATH=
ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-shell-test.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

for file in \
  "$ROOT/.profile" \
  "$ROOT/.config/sh/.shrc" \
  "$ROOT"/.config/sh/profile.d/*.sh \
  "$ROOT"/.config/sh/sh.d/*.sh; do
  sh -n "$file"
done

sh "$ROOT/.config/dotfiles/tests/shell-bash.sh"

for file in \
  "$ROOT/.config/zsh/.zprofile" \
  "$ROOT/.config/zsh/.zshrc" \
  "$ROOT"/.config/zsh/zsh.d/*.zshrc \
  "$ROOT/.config/spaceship.zsh"; do
  zsh -n "$file"
done

for shell in sh zsh; do
  command -v "$shell" > /dev/null
  "$shell" "$ROOT/.config/dotfiles/tests/source-cache.sh" "$ROOT" "$TMP/$shell"
done

make_home() {
  mkdir -p "$1/.config" "$1/.local/share" "$1/.cache" "$1/.local/state"
  ln -s "$ROOT/.profile" "$1/.profile"

  ln -s "$ROOT/.zshenv" "$1/.zshenv"
  ln -s "$ROOT/.config/sh" "$1/.config/sh"
  ln -s "$ROOT/.config/zsh" "$1/.config/zsh"
  ln -s "$ROOT/.config/spaceship.zsh" "$1/.config/spaceship.zsh"
}

HOME_DIR="$TMP/home"
make_home "$HOME_DIR"
ln -s "$ROOT/.local/share/zsh" "$HOME_DIR/.local/share/zsh"

ZSH=$(command -v zsh)
env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=xterm TERM_PROGRAM=zellij \
  XDG_CONFIG_HOME="$HOME_DIR/.config" XDG_DATA_HOME="$HOME_DIR/.local/share" \
  XDG_STATE_HOME="$HOME_DIR/.local/state" XDG_CACHE_HOME="$HOME_DIR/.cache" \
  ENV="$HOME_DIR/.config/sh/.shrc" sh -ic exit

# shellcheck disable=SC2016
COMPDEF_CHECK='(( ${+functions[compdef]} ))'
env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=xterm TERM_PROGRAM=zellij \
  HOMEBREW_PREFIX=/nonexistent "$ZSH" -d -lic "$COMPDEF_CHECK"
env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=xterm TERM_PROGRAM=zellij \
  HOMEBREW_PREFIX=/nonexistent "$ZSH" -d -lic 'zsh -d -ic "(( \${+functions[compdef]} && \${+functions[_zsh_autosuggest_accept]} && \${+functions[_zsh_highlight]} )) && zle -l autosuggest-accept >/dev/null && bindkey -M viins | grep -q autosuggest-accept"'

# Absence: uninitialized submodules leave empty directories; zsh startup must stay silent and succeed.
# Bash is excluded: it sources no submodule files and writes job-control noise to stderr without a TTY.
ABSENT_HOME="$TMP/absent"
make_home "$ABSENT_HOME"
for dir in \
  plugins/fast-syntax-highlighting \
  plugins/zsh-autosuggestions \
  themes/spaceship-prompt; do
  mkdir -p "$ABSENT_HOME/.local/share/zsh/$dir"
done
if ! ERR=$(env -i HOME="$ABSENT_HOME" PATH=/usr/bin:/bin TERM=xterm TERM_PROGRAM=zellij \
  HOMEBREW_PREFIX=/nonexistent "$ZSH" -d -lic exit 2>&1 > /dev/null) || [ -n "$ERR" ]; then
  printf 'FAIL: zsh startup without submodules\n%s\n' "$ERR" >&2
  exit 1
fi

printf 'shell tests: ok\n'
