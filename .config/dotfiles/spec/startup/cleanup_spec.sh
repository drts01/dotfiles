# shellcheck shell=sh disable=SC2016 # Startup commands are evaluated in child shells.

Describe 'shared startup ordering and strict-mode safety'
Before 'setup_home'
After 'cleanup_home'

prepare_order() {
  rm "$HOME_DIR/.config/sh"
  cp -R "$ROOT/.config/sh" "$HOME_DIR/.config/sh"
  fake_bin sk 'printf ":\n"'
  fake_bin mise 'printf ":\n"'
  printf 'printf "05 " >> "$HOME/order"\n' > "$HOME_DIR/.config/sh/sh.d/05_order.sh"
  printf 'alias fzf >/dev/null || return 1; case ${_shell-} in zsh) command -v compdef >/dev/null || return 1 ;; esac; printf "35 " >> "$HOME/order"\n' > "$HOME_DIR/.config/sh/sh.d/35_order.sh"
  printf 'case ${_shell-} in bash | zsh) [ -s "$XDG_CACHE_HOME/shell/mise.$_shell" ] || return 1 ;; esac; printf "45 " >> "$HOME/order"\n' > "$HOME_DIR/.config/sh/sh.d/45_order.sh"
  printf 'printf "95" >> "$HOME/order"\n' > "$HOME_DIR/.config/sh/sh.d/95_order.sh"
}

check_order() {
  prepare_order || return
  case $1 in
    sh)
      without_job_control_noise run_isolated env PATH="$BIN:/usr/bin:/bin" XDG_CONFIG_HOME="$HOME_DIR/.config" XDG_DATA_HOME="$HOME_DIR/.local/share" XDG_STATE_HOME="$HOME_DIR/.local/state" XDG_CACHE_HOME="$HOME_DIR/.cache" ENV="$HOME_DIR/.config/sh/.shrc" /bin/sh -ic 'test "$(cat "$HOME/order")" = "05 35 45 95"'
      ;;
    bash)
      without_job_control_noise run_isolated env PATH="$BIN:/usr/bin:/bin" bash -lic 'test "$(cat "$HOME/order")" = "05 35 45 95"'
      ;;
    zsh)
      run_isolated env PATH="$BIN:/usr/bin:/bin" zsh -d -lic 'test "$(cat "$HOME/order")" = "05 35 45 95"'
      ;;
  esac
}

It 'loads every shared module in lexical order in the OS shell'
When run check_order sh
The status should be success
The error should be blank
End

Context 'Bash'
Skip if 'Bash unavailable or disabled' skip_shell bash
It 'loads every shared module in lexical order'
When run check_order bash
The status should be success
The error should be blank
End

It 'starts login and interactive Bash under nounset without diagnostics'
When run without_job_control_noise run_isolated env TERM_PROGRAM=unknown bash -u -lic 'bash -u -ic ":"'
The status should be success
The error should be blank
End

It 'installs OSC 133 command and prompt markers when supported'
When run without_job_control_noise run_isolated bash -lic '[[ $PS0 == *"133;C"* && $PROMPT_COMMAND == *"_bash_osc133_prompt"* && $PS1 == *"133;B"* ]]'
The status should be success
End

It 'does not install OSC 133 without a supported terminal'
When run without_job_control_noise run_isolated env -u ZELLIJ bash -lic '[[ -z ${PS0-} && ${PROMPT_COMMAND-} != *"_bash_osc133_prompt"* && $PS1 != *"133;B"* ]]'
The status should be success
End
End

Context 'Zsh'
Skip if 'Zsh unavailable' skip_shell zsh
It 'loads every shared module in lexical order after compinit'
When run check_order zsh
The status should be success
The error should be blank
End

It 'starts login and interactive Zsh under nounset without diagnostics'
When run run_isolated zsh -d -o nounset -lic 'zsh -d -o nounset -ic ":"'
The status should be success
The error should be blank
End

It 'installs OSC 133 hooks when supported'
When run run_isolated zsh -d -lic '(( ${+functions[_osc133_precmd]} && ${+functions[_osc133_preexec]} && ${+functions[_inject_osc133_b]} )) && [[ "${precmd_functions[*]}" == *"_inject_osc133_b"* ]]'
The status should be success
End

It 'does not install OSC 133 without a supported terminal'
When run run_isolated env -u ZELLIJ zsh -d -lic '(( ! ${+functions[_osc133_precmd]} && ! ${+functions[_osc133_preexec]} ))'
The status should be success
End
End

Context 'OS shell'
It 'sources the profile and starts interactive OS shell under nounset without diagnostics'
# Source the profile explicitly: some system /etc/profile scripts fail under nounset.
When run without_job_control_noise run_isolated env XDG_CONFIG_HOME="$HOME_DIR/.config" XDG_DATA_HOME="$HOME_DIR/.local/share" XDG_STATE_HOME="$HOME_DIR/.local/state" XDG_CACHE_HOME="$HOME_DIR/.cache" ENV="$HOME_DIR/.config/sh/.shrc" /bin/sh -u -ic '. "$HOME/.profile"; /bin/sh -u -ic ":"'
The status should be success
The error should be blank
End

It 'adds OSC 133 prompt markers when supported'
When run without_job_control_noise run_isolated env XDG_CONFIG_HOME="$HOME_DIR/.config" XDG_DATA_HOME="$HOME_DIR/.local/share" XDG_STATE_HOME="$HOME_DIR/.local/state" XDG_CACHE_HOME="$HOME_DIR/.cache" ENV="$HOME_DIR/.config/sh/.shrc" /bin/sh -ic 'case ${BASH_VERSION-} in ?*) : ;; *) printf %s "$PS1" | grep -q "133;B" ;; esac'
The status should be success
End

It 'does not add OSC 133 without a supported terminal'
When run without_job_control_noise run_isolated env -u ZELLIJ XDG_CONFIG_HOME="$HOME_DIR/.config" ENV="$HOME_DIR/.config/sh/.shrc" /bin/sh -ic 'case $PS1 in *"133;B"*) exit 1 ;; esac'
The status should be success
End
End
End
