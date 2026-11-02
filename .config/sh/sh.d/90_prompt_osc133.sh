# shellcheck shell=sh

if [ -z "${PS1-}" ]; then
  if [ -n "${USER-}" ] && [ -n "${HOSTNAME-}" ]; then
    PS1="$USER@$HOSTNAME:\${PWD##*/} \$ "
  else
    PS1='$ '
  fi
fi

# Alacritty does not support OSC 133: https://github.com/alacritty/alacritty/issues/5850
# shellcheck disable=SC2154
case $_shell in
  sh)
    if [ -n "${ZELLIJ-}" ] || [ "${TERM_PROGRAM-}" = Ghostty ] || [ "${TERM_PROGRAM-}" = WezTerm ] || [ "${TERM_PROGRAM-}" = iTerm.app ]; then
      _osc133_a=$(printf '\033]133;A\033\134')
      _osc133_b=$(printf '\033]133;B\033\134')
      if [ -n "${STARSHIP_SHELL-}" ]; then
        PS1="${_osc133_a}\$(starship prompt)${_osc133_b}"
      else
        PS1="${_osc133_a}${PS1:-$ }${_osc133_b}"
      fi
      export PS1
      unset _osc133_a _osc133_b
    fi
    ;;
esac
