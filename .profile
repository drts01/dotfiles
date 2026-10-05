
# XDG -- https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME

if [ -n "${ZSH_VERSION-}" ]; then
  _shell=zsh
elif [ -n "${BASH_VERSION-}" ]; then
  _shell=bash
else
  # shellcheck disable=SC2209
  _shell=sh
fi

readonly _shell

SH_CONF="$XDG_CONFIG_HOME/sh/env.d"
# shellcheck disable=SC1091
if [ -z "$_PROFILE_SOURCED" ]; then
  export _PROFILE_SOURCED=1
  . "$SH_CONF/10_functions.sh"
  . "$SH_CONF/20_env.sh"
fi

# Set ENV for interactive POSIX shells
# Strict POSIX-compliant shell (like sh, dash, or ksh) does not automatically look for an RC file
export ENV="$XDG_CONFIG_HOME/.shrc"
