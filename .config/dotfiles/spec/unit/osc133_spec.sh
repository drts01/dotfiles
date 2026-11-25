# shellcheck shell=sh disable=SC2016 # Commands are evaluated in child shells.

Describe 'Zsh OSC133 prompt markers'
Skip if 'Zsh is not installed' skip_shell zsh
Before 'setup_home' 'require_shell zsh'
After 'cleanup_home'

osc133_prompt() {
  run_isolated zsh -dfc '
    TERM_PROGRAM=Ghostty
    unset ZELLIJ
    PROMPT="plain> "
    source "$1"
    marker=$(printf "\033]133;B\007")
    expected="plain> %{$marker%}"
    _inject_osc133_b
    [[ $PROMPT == "$expected" ]] || exit 1
    _inject_osc133_b
    [[ $PROMPT == "$expected" ]] || exit 2
    source "$1"
    _inject_osc133_b
    [[ $PROMPT == "$expected" && ${#precmd_functions} == 2 && ${#preexec_functions} == 1 ]] || exit 3
    PROMPT="replacement> "
    _inject_osc133_b
    [[ $PROMPT == "replacement> %{$marker%}" ]]
  ' zsh "$ROOT/.config/zsh/zsh.d/90_osc133.zshrc"
}

osc133_disabled() {
  run_isolated zsh -dfc '
    unset ZELLIJ TERM_PROGRAM
    PROMPT="plain> "
    source "$1"
    [[ $PROMPT == "plain> " && ${+functions[_inject_osc133_b]} == 0 ]]
  ' zsh "$ROOT/.config/zsh/zsh.d/90_osc133.zshrc"
}

It 'appends actual ESC/BEL bytes exactly once without a prompt framework'
When run osc133_prompt
The status should be success
The output should be blank
The error should be blank
End

It 'does not install markers for an unsupported terminal'
When run osc133_disabled
The status should be success
The output should be blank
The error should be blank
End
End
