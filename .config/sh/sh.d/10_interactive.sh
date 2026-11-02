# shellcheck shell=sh

# History and editing mode belong to each interactive shell, not the parent login shell.
# shellcheck disable=SC2154
HISTFILE="$XDG_STATE_HOME/.${_shell}_history"
HISTSIZE=20000
set -o vi
# Zsh reads this variable when vi keymaps are enabled.
# shellcheck disable=SC2034
KEYTIMEOUT=1
