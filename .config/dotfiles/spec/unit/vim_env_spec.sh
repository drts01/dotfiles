# shellcheck shell=sh

Describe 'Vim XDG startup environment'
Before 'setup_home'
After 'cleanup_home'

load_vim_env() {
  HOME=$HOME_DIR
  XDG_CONFIG_HOME="$TEST_TMP/config with spaces"
  XDG_DATA_HOME="$TEST_TMP/data"
  mkdir -p "$XDG_CONFIG_HOME/vim"
  case $1 in
    missing) unset VIMINIT ;;
    unset)
      unset VIMINIT
      : > "$XDG_CONFIG_HOME/vim/vimrc"
      ;;
    *)
      VIMINIT=$1
      : > "$XDG_CONFIG_HOME/vim/vimrc"
      ;;
  esac
  has() { return 1; }
  path_add() { :; }
  # shellcheck disable=SC1090
  . "$ROOT/.config/sh/profile.d/20_env.sh"
  printf '%s\n' "${VIMINIT-unset}"
}

It 'sources the XDG configuration without shell-expanding its path'
When call load_vim_env unset
# shellcheck disable=SC2016
The output should equal 'execute "source " . fnameescape($XDG_CONFIG_HOME . "/vim/vimrc")'
The error should be blank
End

It 'preserves an existing startup command'
When call load_vim_env 'set number'
The output should equal 'set number'
End

It 'preserves an explicitly empty startup command'
When call load_vim_env ''
The output should be blank
End

It 'does not point Vim at a missing configuration'
When call load_vim_env missing
The output should equal unset
End
End
