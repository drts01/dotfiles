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

for file in \
  "$ROOT/.bash_profile" \
  "$ROOT/.bashrc"; do
  bash -n "$file"
done

for file in \
  "$ROOT/.config/zsh/.zprofile" \
  "$ROOT/.config/zsh/.zshrc" \
  "$ROOT"/.config/zsh/zsh.d/*.zshrc \
  "$ROOT/.config/spaceship.zsh"; do
  zsh -n "$file"
done

for shell in sh bash zsh; do
  command -v "$shell" > /dev/null
  "$shell" "$ROOT/.config/dotfiles/tests/source-cache.sh" "$ROOT" "$TMP/$shell"
done

HOME_DIR="$TMP/home"
mkdir -p "$HOME_DIR/.config" "$HOME_DIR/.local/share" "$HOME_DIR/.cache" "$HOME_DIR/.local/state"
ln -s "$ROOT/.profile" "$HOME_DIR/.profile"
ln -s "$ROOT/.bash_profile" "$HOME_DIR/.bash_profile"
ln -s "$ROOT/.bashrc" "$HOME_DIR/.bashrc"
ln -s "$ROOT/.zshenv" "$HOME_DIR/.zshenv"
ln -s "$ROOT/.config/sh" "$HOME_DIR/.config/sh"
ln -s "$ROOT/.config/zsh" "$HOME_DIR/.config/zsh"
ln -s "$ROOT/.config/spaceship.zsh" "$HOME_DIR/.config/spaceship.zsh"
ln -s "$ROOT/.local/share/zsh" "$HOME_DIR/.local/share/zsh"

BASH=$(command -v bash)
ZSH=$(command -v zsh)
env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=xterm TERM_PROGRAM=zellij \
  XDG_CONFIG_HOME="$HOME_DIR/.config" XDG_DATA_HOME="$HOME_DIR/.local/share" \
  XDG_STATE_HOME="$HOME_DIR/.local/state" XDG_CACHE_HOME="$HOME_DIR/.cache" \
  ENV="$HOME_DIR/.config/sh/.shrc" sh -ic exit
env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=xterm TERM_PROGRAM=zellij \
  HOMEBREW_PREFIX=/nonexistent "$BASH" --noprofile --rcfile "$HOME_DIR/.bashrc" -ic exit
# shellcheck disable=SC2016
COMPDEF_CHECK='(( ${+functions[compdef]} ))'
env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=xterm TERM_PROGRAM=zellij \
  HOMEBREW_PREFIX=/nonexistent "$ZSH" -d -lic "$COMPDEF_CHECK"
env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=xterm TERM_PROGRAM=zellij \
  HOMEBREW_PREFIX=/nonexistent "$ZSH" -d -lic 'zsh -d -ic exit'

printf 'shell tests: ok\n'
