# shellcheck shell=sh

Describe 'interactive history in the selected shell'
Before 'setup_home'
After 'cleanup_home'

load_history() {
  _shell='test'
  # shellcheck disable=SC1090
  . "$ROOT/.config/sh/sh.d/10_interactive.sh"
}

create_history_directory() {
  XDG_STATE_HOME="$TEST_TMP/new state/nested"
  load_history
  [ -d "$XDG_STATE_HOME" ] && [ "$HISTFILE" = "$XDG_STATE_HOME/.test_history" ] && [ "$HISTSIZE" = 20000 ]
}

default_history_directory() {
  HOME="$HOME_DIR"
  unset XDG_STATE_HOME
  load_history
  [ "$HISTFILE" = "$HOME/.local/state/.test_history" ] && [ -d "$HOME/.local/state" ]
}

retain_history() {
  XDG_STATE_HOME="$HOME_DIR/.local/state"
  printf 'saved history\n' > "$XDG_STATE_HOME/.test_history"
  load_history
  load_history
  [ "$(cat "$HISTFILE")" = 'saved history' ]
}

failed_history_directory() {
  XDG_STATE_HOME="$TEST_TMP/not-a-directory/nested"
  : > "$TEST_TMP/not-a-directory"
  unset HISTFILE
  load_history
  [ -z "${HISTFILE-}" ] && [ "$HISTSIZE" = 20000 ]
}

It 'creates a missing state directory including spaces before setting HISTFILE'
When run create_history_directory
The status should be success
The error should be blank
End

It 'uses the standard state directory when XDG_STATE_HOME is unset'
When run default_history_directory
The status should be success
The error should be blank
End

It 'preserves existing history when sourced repeatedly'
When run retain_history
The status should be success
The error should be blank
End

It 'reports a directory creation failure without assigning an unusable HISTFILE'
When run failed_history_directory
The status should be success
The error should include "$TEST_TMP/not-a-directory/nested"
End
End
