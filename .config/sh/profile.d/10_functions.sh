# shellcheck shell=sh

if [ -z "${_shell-}" ]; then
  if [ -n "${ZSH_VERSION-}" ]; then
    _shell=zsh
  elif [ -n "${BASH_VERSION-}" ]; then
    _shell=bash
  else
    # shellcheck disable=SC2209
    _shell=sh
  fi
  readonly _shell
fi

if [ "$_shell" = bash ] || [ "$_shell" = zsh ]; then
  # OSTYPE is supplied by Bash and Zsh; POSIX sh uses uname below.
  # shellcheck disable=SC3028
  case ${OSTYPE-} in
    darwin*) LOCAL_OS=darwin ;;
    linux*) LOCAL_OS=linux ;;
    *) LOCAL_OS=unknown ;;
  esac
else
  case "$(uname -s)" in
    Darwin) LOCAL_OS=darwin ;;
    Linux) LOCAL_OS=linux ;;
    *) LOCAL_OS=unknown ;;
  esac
fi
export LOCAL_OS

path_add() {
  # Prefix variables with function name to prevent global pollution
  _pa_dir="$1"
  case ":$PATH:" in
    *":$_pa_dir:"*) ;;
    *) export PATH="$_pa_dir:$PATH" ;;
  esac
  unset _pa_dir
}

has() {
  case $_shell in
    zsh) whence -p "$1" > /dev/null 2>&1 ;; # Ignore aliases, as the commands table did.
    *) command -v "$1" > /dev/null 2>&1 ;;
  esac
}

# Cache and source shell code emitted by a command (for example, `zoxide init`).
# Refreshes stale output atomically and byte-compiles it when running under Zsh.
# Usage: source_cache CACHE_FILE COMMAND [ARG ...]
source_cache() {
  _sc_file=$1
  shift
  if ! _sc_bin=$(command -v "$1"); then
    unset _sc_file _sc_bin
    return 0
  fi
  if [ ! -s "$_sc_file" ] || { [ -f "$_sc_bin" ] && [ "$_sc_file" -ot "$_sc_bin" ]; }; then
    _sc_tmp="$_sc_file.$$"
    if mkdir -p "${_sc_file%/*}" && "$@" > "$_sc_tmp" && mv "$_sc_tmp" "$_sc_file"; then
      [ "${_shell-}" = zsh ] && zcompile "$_sc_file"
    fi
    rm -f "${_sc_tmp-}"
  fi
  # shellcheck disable=SC1090
  [ -s "$_sc_file" ] && . "$_sc_file"
  unset _sc_file _sc_bin _sc_tmp
}
