# shellcheck shell=sh disable=SC2016 # Commands are evaluated in child shells.

skip_nested_shells() {
  skip_shell bash || skip_shell zsh
}

Describe 'nested interactive shells'
Before 'setup_home'
After 'cleanup_home'

Context 'from Bash login'
Skip if 'Bash or Zsh unavailable' skip_nested_shells

It 'selects Zsh history and vi mode in an interactive Zsh child'
When run without_job_control_noise run_isolated bash -lic 'zsh -d -ic '\''[[ $HISTFILE == $XDG_STATE_HOME/.zsh_history && $HISTSIZE == 20000 && -o vi ]]'\'''
The status should be success
The error should be blank
End

It 'selects the implementation history and vi mode in an interactive OS shell child'
When run without_job_control_noise run_isolated bash -lic '/bin/sh -ic '\''case ${BASH_VERSION-} in ?*) history_file=.bash_history ;; *) history_file=.sh_history ;; esac; [ "$HISTFILE" = "$XDG_STATE_HOME/$history_file" ] && [ "$HISTSIZE" = 20000 ] && set -o | grep -Eq "^vi[[:space:]]+on$"'\'''
The status should be success
The error should be blank
End
End

Context 'from Zsh login'
Skip if 'Bash or Zsh unavailable' skip_nested_shells

It 'selects Bash history and vi mode in an interactive Bash child'
When run without_job_control_noise run_isolated zsh -d -lic 'bash -ic '\''[ "$HISTFILE" = "$XDG_STATE_HOME/.bash_history" ] && [ "$HISTSIZE" = 20000 ] && set -o | grep -Eq "^vi[[:space:]]+on$"'\'''
The status should be success
The error should be blank
End
End

End
