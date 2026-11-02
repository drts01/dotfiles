# shellcheck shell=bash

# shellcheck source=/dev/null
. "$HOME/.profile"
# shellcheck source=/dev/null
. "$XDG_CONFIG_HOME/sh/.shrc"

HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignoredups:erasedups
shopt -s cmdhist histappend
export HISTFILESIZE HISTCONTROL

# Alacritty does not support OSC 133: https://github.com/alacritty/alacritty/issues/5850
if [[ -n ${ZELLIJ-} || ${TERM_PROGRAM-} == Ghostty || ${TERM_PROGRAM-} == WezTerm || ${TERM_PROGRAM-} == iTerm.app ]]; then
  export PS0='\[\e]133;C\]'

  _bash_osc133_prompt() {
    local exit_status=$?
    printf '\e]133;D;%s\a\e]133;A\a' "$exit_status"
  }

  if [[ ${PROMPT_COMMAND-} != *_bash_osc133_prompt* ]]; then
    PROMPT_COMMAND="_bash_osc133_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
  fi
  if [[ ${PS1-} != *'133;B'* ]]; then
    export PS1="${PS1-}"'\[\e]133;B\]'
  fi
fi
