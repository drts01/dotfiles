#!/bin/sh
set -eu

CDPATH=
command -v hyperfine > /dev/null || {
  echo 'hyperfine is required' >&2
  exit 127
}

ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-shell-bench.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
HOME_DIR="$TMP/home"

mkdir -p "$HOME_DIR/.config" "$HOME_DIR/.local/share" "$HOME_DIR/.cache" "$HOME_DIR/.local/state"
ln -s "$ROOT/.profile" "$HOME_DIR/.profile"
ln -s "$ROOT/.zshenv" "$HOME_DIR/.zshenv"
ln -s "$ROOT/.config/sh" "$HOME_DIR/.config/sh"
ln -s "$ROOT/.config/zsh" "$HOME_DIR/.config/zsh"
ln -s "$ROOT/.config/spaceship.zsh" "$HOME_DIR/.config/spaceship.zsh"
ln -s "$ROOT/.local/share/zsh" "$HOME_DIR/.local/share/zsh"

ZSH=$(command -v zsh)
RUNS=${RUNS:-20}
ZSH_CMD="env -i HOME='$HOME_DIR' PATH=/usr/bin:/bin TERM=xterm TERM_PROGRAM=zellij HOMEBREW_PREFIX=/nonexistent '$ZSH' -d -lic exit"
SH_CMD="env -i HOME='$HOME_DIR' PATH=/usr/bin:/bin TERM=xterm TERM_PROGRAM=zellij XDG_CONFIG_HOME='$HOME_DIR/.config' ENV='$HOME_DIR/.config/sh/.shrc' sh -ic exit"

hyperfine --warmup 3 --runs "$RUNS" \
  --command-name 'zsh login' "$ZSH_CMD" \
  --command-name 'POSIX sh interactive' "$SH_CMD"
