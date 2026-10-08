# shellcheck shell=bash

# shellcheck source=/dev/null
. "$HOME/.profile"
# shellcheck source=/dev/null
. "$XDG_CONFIG_HOME/sh/.shrc"

HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignoredups:erasedups
shopt -s cmdhist histappend
export HISTFILESIZE HISTCONTROL
