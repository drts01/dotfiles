# shellcheck shell=sh

ROOT=$(cd -- "$SHELLSPEC_PROJECT_ROOT/../.." && pwd)

make_home() {
  mkdir -p "$1/.config" "$1/.local/share" "$1/.local/state" "$1/.cache"
  ln -s "$ROOT/.profile" "$1/.profile"
  ln -s "$ROOT/.bash_profile" "$1/.bash_profile"
  ln -s "$ROOT/.bashrc" "$1/.bashrc"
  ln -s "$ROOT/.zshenv" "$1/.zshenv"
  ln -s "$ROOT/.config/sh" "$1/.config/sh"
  ln -s "$ROOT/.config/zsh" "$1/.config/zsh"
  ln -s "$ROOT/.config/spaceship.zsh" "$1/.config/spaceship.zsh"
}

setup_home() {
  TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-spec.XXXXXX") || return
  HOME_DIR=$TEST_TMP/home
  BIN=$TEST_TMP/bin
  mkdir -p "$BIN"
  make_home "$HOME_DIR"
}

cleanup_home() {
  rm -rf "$TEST_TMP"
}

run_isolated() {
  env -i HOME="$HOME_DIR" PATH=/usr/bin:/bin TERM=dumb ZELLIJ=0 \
    HOMEBREW_PREFIX=/nonexistent "$@"
}

without_job_control_noise() {
  "$@" 2> "$TEST_TMP/stderr"
  result=$?
  sed -e '/no job control in this shell/d' \
    -e '/job control turned off/d' -e '/can.t access tty/d' \
    -e '/cannot set terminal process group .*Inappropriate ioctl for device/d' "$TEST_TMP/stderr" >&2
  return "$result"
}

fake_bin() {
  printf '#!/bin/sh\n%s\n' "$2" > "$BIN/$1"
  chmod +x "$BIN/$1"
}

skip_shell() {
  case $1 in
    bash)
      case ${TEST_BASH:-auto} in
        skip) return 0 ;;
        auto)
          ! command -v bash > /dev/null 2>&1
          return $?
          ;;
        required) return 1 ;;
      esac
      ;;
  esac
  ! command -v "$1" > /dev/null 2>&1
}

require_shell() {
  case ${TEST_BASH:-auto} in
    auto | skip | required) ;;
    *)
      printf 'TEST_BASH must be required, skip, or auto\n' >&2
      return 1
      ;;
  esac
  if [ "$1" = bash ] && [ "${TEST_BASH:-auto}" = required ]; then
    command -v bash > /dev/null 2>&1 || {
      printf 'Bash is required by TEST_BASH=required\n' >&2
      return 1
    }
  fi
}
