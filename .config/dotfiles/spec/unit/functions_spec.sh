# shellcheck shell=sh

Describe 'shared profile functions in the selected shell'
Before 'setup_home'
After 'cleanup_home'

load_functions() {
  _shell=
  # shellcheck disable=SC1090
  . "$ROOT/.config/sh/profile.d/10_functions.sh"
}

existing_command() {
  load_functions
  has sh
}

missing_command() {
  load_functions
  ! has command-that-does-not-exist
}

prepend_path() {
  load_functions
  path_add "$TEST_TMP/new"
  case $PATH in "$TEST_TMP/new:"*) ;; *) return 1 ;; esac
}

alias_is_not_a_command() {
  load_functions
  [ "$_shell" = zsh ] || return 0
  alias command-that-does-not-exist=sh
  ! has command-that-does-not-exist
}

deduplicate_path() {
  load_functions
  path_add "$TEST_TMP/new"
  before=$PATH
  path_add "$TEST_TMP/new"
  [ "$PATH" = "$before" ]
}

It 'has detects an existing command'
When run existing_command
The status should be success
End

It 'has rejects a missing command'
When run missing_command
The status should be success
End

It 'does not treat a Zsh alias as an executable command'
When run alias_is_not_a_command
The status should be success
End

It 'path_add prepends a directory'
When run prepend_path
The status should be success
End

It 'path_add does not duplicate a directory'
When run deduplicate_path
The status should be success
End
End
