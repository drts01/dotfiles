# shellcheck shell=sh

Describe 'eza aliases in the selected shell'
Before 'setup_home'
After 'cleanup_home'

load_aliases() {
  has() { [ "$1" = eza ]; }
  eza() {
    printf '%s\n' "$@"
    return "$EZA_STATUS"
  }
  # shellcheck disable=SC1090
  . "$ROOT/.config/sh/sh.d/20_aliases.sh"
}

run_ls() {
  load_aliases
  EZA_STATUS=$1
  shift
  ls "$@"
}

run_ll() {
  load_aliases
  EZA_STATUS=23
  ll 'two words'
}

It 'returns an eza failure status and preserves arguments'
When run run_ls 23 'two words'
The status should equal 23
The output should equal "$(printf '%s\n' --across --all --git --group-directories-first 'two words')"
The error should be blank
End

It 'returns success and enables icons for long listings'
When run run_ls 0 -l 'two words'
The status should be success
The output should equal "$(printf '%s\n' --across --all --git --group-directories-first --icons=auto -l 'two words')"
The error should be blank
End

It 'propagates eza failure through ll'
When run run_ll
The status should equal 23
The output should equal "$(printf '%s\n' --across --all --git --group-directories-first --icons=auto --long --header 'two words')"
The error should be blank
End
End
