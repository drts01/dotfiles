# shellcheck shell=sh

Describe 'Vim XDG startup environment'
Before 'setup_home'
After 'cleanup_home'

load_vim_env() {
  HOME=$HOME_DIR
  XDG_CONFIG_HOME="$TEST_TMP/config with spaces"
  XDG_DATA_HOME="$TEST_TMP/data"
  PATH="$BIN:/usr/bin:/bin"
  mkdir -p "$XDG_CONFIG_HOME/vim"
  # The fake executables read their own environment, not the test shell's.
  # shellcheck disable=SC2016
  fake_bin vim 'printf "%s\n" "${VIMINIT-unset}"'
  # shellcheck disable=SC2016
  fake_bin nvim 'printf "%s\n" "${VIMINIT-unset}"'
  case $1 in
    missing) unset VIMINIT ;;
    unset)
      unset VIMINIT
      : > "$XDG_CONFIG_HOME/vim/vimrc"
      ;;
    *)
      VIMINIT=$1
      export VIMINIT
      : > "$XDG_CONFIG_HOME/vim/vimrc"
      ;;
  esac
  has() { [ "$1" = vim ] || [ "$1" = nvim ]; }
  path_add() { :; }
  # shellcheck disable=SC1090
  . "$ROOT/.config/sh/profile.d/20_env.sh"
  # The wrapper deliberately receives no arguments in these environment probes.
  # shellcheck disable=SC2119
  case ${2-vim} in
    parent)
      vim > /dev/null
      printf '%s\n' "${VIMINIT-unset}"
      ;;
    nvim) command nvim ;;
    *) vim ;;
  esac
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

It 'does not export VIMINIT to the parent environment'
When call load_vim_env unset parent
The output should equal unset
End

It 'does not override Neovim initialization'
When call load_vim_env unset nvim
The output should equal unset
End
End
