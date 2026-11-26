# shellcheck shell=sh disable=SC2016 # Commands are evaluated in child shells.

Describe 'Zsh OSC133 prompt markers'
Skip if 'Zsh is not installed' skip_shell zsh
Before 'setup_home' 'require_shell zsh'
After 'cleanup_home'

osc133_prompt() {
  run_isolated zsh -dfic '
    TERM_PROGRAM=$2
    unset ZELLIJ
    [[ -n $TERM_PROGRAM ]] || unset TERM_PROGRAM
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
  ' zsh "$ROOT/.config/zsh/zsh.d/90_osc133.zshrc" "$1"
}

osc133_disabled() {
  run_isolated zsh -dfc '
    unset ZELLIJ TERM_PROGRAM
    PROMPT="plain> "
    source "$1"
    [[ $PROMPT == "plain> " && ${+functions[_inject_osc133_b]} == 0 ]]
  ' zsh "$ROOT/.config/zsh/zsh.d/90_osc133.zshrc"
}

It 'supports standalone Rio and appends actual ESC/BEL bytes exactly once'
When run osc133_prompt rio
The status should be success
The output should be blank
The error should be blank
End

osc133_lifecycle() {
  run_isolated zsh -dfic '
    source "$1"
    _osc133_precmd > "$2"
    [[ $(<"$2") == $'"'"'\e]133;A\a'"'"' ]] || exit 1
    _osc133_preexec > "$2"
    [[ $(<"$2") == $'"'"'\e]133;C\a'"'"' ]] || exit 2
    (exit 7)
    _osc133_precmd > "$2"
    [[ $(<"$2") == $'"'"'\e]133;D;7\a\e]133;A\a'"'"' ]] || exit 3
    _osc133_precmd > "$2"
    [[ $(<"$2") == $'"'"'\e]133;A\a'"'"' ]]
  ' zsh "$ROOT/.config/zsh/zsh.d/90_osc133.zshrc" "$TEST_TMP/markers"
}

osc133_opt_out() {
  run_isolated zsh -dfic '
    DOTFILES_OSC133=0
    source "$1"
    (( ! ${+functions[_osc133_precmd]} )) || exit 1
    unset DOTFILES_OSC133
    _rio_state=0
    source "$1"
    (( ! ${+functions[_osc133_precmd]} ))
  ' zsh "$ROOT/.config/zsh/zsh.d/90_osc133.zshrc"
}

It 'reports a completion status only after a command starts'
When run osc133_lifecycle
The status should be success
The output should be blank
The error should be blank
End

It 'defers to the opt-out and native Rio integration'
When run osc133_opt_out
The status should be success
The output should be blank
The error should be blank
End

It 'installs markers for an unrecognized terminal'
When run osc133_prompt unknown
The status should be success
The output should be blank
The error should be blank
End

It 'installs markers without terminal identification'
When run osc133_prompt ''
The status should be success
The output should be blank
The error should be blank
End

It 'does not install markers when sourced non-interactively'
When run osc133_disabled
The status should be success
The output should be blank
The error should be blank
End
End

Describe 'POSIX sh OSC133 prompt markers'
Before 'setup_home'
After 'cleanup_home'

osc133_sh_prompt() {
  without_job_control_noise run_isolated env -u ZELLIJ TERM_PROGRAM="$1" /bin/sh -uic '
    [ -n "$TERM_PROGRAM" ] || unset TERM_PROGRAM
    _shell=sh
    PS1="plain> "
    # An inherited Starship variable must not replace the prompt or require Starship.
    STARSHIP_SHELL=zsh
    . "$1"
    a=$(printf "\033]133;A\033\134")
    b=$(printf "\033]133;B\033\134")
    expected="${a}plain> ${b}"
    [ "$PS1" = "$expected" ] || exit 1
    . "$1"
    [ "$PS1" = "$expected" ]
  ' sh "$ROOT/.config/sh/sh.d/90_prompt_osc133.sh"
}

It 'supports standalone Rio without duplicating markers or replacing the prompt'
When run osc133_sh_prompt rio
The status should be success
The output should be blank
The error should be blank
End

It 'adds markers for standalone Alacritty'
When run osc133_sh_prompt Alacritty
The status should be success
The output should be blank
The error should be blank
End

It 'adds markers without terminal identification'
When run osc133_sh_prompt ''
The status should be success
The output should be blank
The error should be blank
End

It 'does not initialize a prompt when sourced non-interactively'
When run run_isolated /bin/sh -uc 'unset PS1; _shell=sh; . "$1"; [ "${PS1+set}" != set ]' sh "$ROOT/.config/sh/sh.d/90_prompt_osc133.sh"
The status should be success
The output should be blank
The error should be blank
End

It 'honors the opt-out inside Zellij'
When run without_job_control_noise run_isolated env DOTFILES_OSC133=0 /bin/sh -uic '_shell=sh; PS1="plain> "; . "$1"; [ "$PS1" = "plain> " ]' sh "$ROOT/.config/sh/sh.d/90_prompt_osc133.sh"
The status should be success
The output should be blank
The error should be blank
End
End
