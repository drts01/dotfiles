# shellcheck shell=sh

# History and editing mode belong to each interactive shell, not the parent login shell.
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
# shellcheck disable=SC2154
if [ -d "$XDG_STATE_HOME" ] || mkdir -p -- "$XDG_STATE_HOME"; then
  HISTFILE="$XDG_STATE_HOME/.${_shell}_history"
else
  printf 'Cannot create history directory: %s\n' "$XDG_STATE_HOME" >&2
  unset HISTFILE
fi
HISTSIZE=20000
set -o vi
# Zsh reads this variable when vi keymaps are enabled.
# shellcheck disable=SC2034
KEYTIMEOUT=1
