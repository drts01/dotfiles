# shellcheck disable=SC2148

if [ -z "$_shell" ]; then
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
  # shellcheck disable=SC2154
  if [ "$_shell" = 'zsh' ]; then
    ((${+commands[$1]}))
  else
    command -v "$1" > /dev/null 2>&1
  fi
}
