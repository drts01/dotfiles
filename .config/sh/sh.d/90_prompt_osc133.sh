# shellcheck shell=sh

case $- in
  *i*) ;;
  *) return 0 ;;
esac

if [ -z "${PS1-}" ]; then
  if [ -n "${USER-}" ] && [ -n "${HOSTNAME-}" ]; then
    PS1="$USER@$HOSTNAME:\${PWD##*/} \$ "
  else
    PS1='$ '
  fi
fi

# Set DOTFILES_OSC133=0 before startup when another integration emits the markers.
[ "${DOTFILES_OSC133-1}" != 0 ] || return 0

# POSIX sh has no portable preexec hook: emit prompt boundaries only.
case ${_shell-} in
  sh)
    _osc133_a=$(printf '\033]133;A\033\134')
    _osc133_b=$(printf '\033]133;B\033\134')
    case $PS1 in
      *"$_osc133_a"*) ;;
      *) PS1="${_osc133_a}${PS1}" ;;
    esac
    case $PS1 in
      *"$_osc133_b"*) ;;
      *) PS1="${PS1}${_osc133_b}" ;;
    esac
    unset _osc133_a _osc133_b
    ;;
esac
