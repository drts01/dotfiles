# shellcheck shell=sh

Describe 'Bash startup'
Skip if 'Bash unavailable or disabled by TEST_BASH' skip_shell bash
Before 'setup_home' 'require_shell bash'
After 'cleanup_home'

bash_syntax() {
  for file in "$ROOT/.profile" "$ROOT/.bash_profile" "$ROOT/.bashrc" \
    "$ROOT/.config/sh/.shrc" "$ROOT"/.config/sh/profile.d/*.sh \
    "$ROOT"/.config/sh/sh.d/*.sh; do
    bash -n "$file" || return 1
  done
}

bash_startup() {
  mode=$1
  shift
  if [ "$mode" = login ]; then
    without_job_control_noise run_isolated bash -lic "$1"
  else
    without_job_control_noise run_isolated bash --noprofile --rcfile "$HOME_DIR/.bashrc" -ic "$1"
  fi
}

It 'parses Bash and shared POSIX configuration files'
When run bash_syntax
The status should be success
End

Context 'interactive login Bash'
It 'loads the login profile'
When run bash_startup login 'shopt -q login_shell'
The status should be success
The error should be blank
End

It 'detects Bash and loads XDG and ENV'
When run bash_startup login '[ "$_shell" = bash ] && [ "$XDG_CONFIG_HOME" = "$HOME/.config" ] && [ "$ENV" = "$HOME/.config/sh/.shrc" ]'
The status should be success
The error should be blank
End

It 'sets Bash history limits, file, and deduplication'
When run bash_startup login '[ "$HISTSIZE" = 20000 ] && [ "$HISTFILESIZE" = 20000 ] && [ "$HISTFILE" = "$HOME/.local/state/.bash_history" ] && [ "$HISTCONTROL" = ignoredups:erasedups ]'
The status should be success
The error should be blank
End

It 'enables cmdhist and histappend'
When run bash_startup login 'shopt -q cmdhist histappend'
The status should be success
The error should be blank
End

It 'loads the editor, alias, and has function'
When run bash_startup login '[ -n "$EDITOR" ] && alias dotfiles >/dev/null && has bash && ! has command-that-does-not-exist'
The status should be success
The error should be blank
End

It 'adds mise shims to PATH'
When run bash_startup login 'case ":$PATH:" in *":$HOME/.local/share/mise/shims:"*) true ;; *) false ;; esac'
The status should be success
The error should be blank
End

It 'prepends and deduplicates PATH'
When run bash_startup login 'path_add "$HOME/test-path"; case "$PATH" in "$HOME/test-path:"*) ;; *) exit 1 ;; esac; before=$PATH; path_add "$HOME/test-path"; [ "$PATH" = "$before" ]'
The status should be success
The error should be blank
End
End

Context 'non-login interactive Bash'
It 'does not load as a login shell'
When run bash_startup interactive '! shopt -q login_shell'
The status should be success
The error should be blank
End

It 'detects Bash and loads XDG and ENV'
When run bash_startup interactive '[ "$_shell" = bash ] && [ "$XDG_CONFIG_HOME" = "$HOME/.config" ] && [ "$ENV" = "$HOME/.config/sh/.shrc" ]'
The status should be success
The error should be blank
End

It 'sets Bash history limits, file, and deduplication'
When run bash_startup interactive '[ "$HISTSIZE" = 20000 ] && [ "$HISTFILESIZE" = 20000 ] && [ "$HISTFILE" = "$HOME/.local/state/.bash_history" ] && [ "$HISTCONTROL" = ignoredups:erasedups ]'
The status should be success
The error should be blank
End

It 'enables cmdhist and histappend'
When run bash_startup interactive 'shopt -q cmdhist histappend'
The status should be success
The error should be blank
End

It 'loads the editor, alias, and has function'
When run bash_startup interactive '[ -n "$EDITOR" ] && alias dotfiles >/dev/null && has bash && ! has command-that-does-not-exist'
The status should be success
The error should be blank
End

It 'adds mise shims to PATH'
When run bash_startup interactive 'case ":$PATH:" in *":$HOME/.local/share/mise/shims:"*) true ;; *) false ;; esac'
The status should be success
The error should be blank
End

It 'prepends and deduplicates PATH'
When run bash_startup interactive 'path_add "$HOME/test-path"; case "$PATH" in "$HOME/test-path:"*) ;; *) exit 1 ;; esac; before=$PATH; path_add "$HOME/test-path"; [ "$PATH" = "$before" ]'
The status should be success
The error should be blank
End
End
End
