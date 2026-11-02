# shellcheck shell=sh

# History and editing mode belong to each interactive shell, not the parent login shell.
HISTFILE="$XDG_STATE_HOME/.${_shell}_history"
HISTSIZE=20000
set -o vi
KEYTIMEOUT=1
