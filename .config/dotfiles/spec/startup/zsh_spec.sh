# shellcheck shell=sh

Describe 'Zsh startup'
Skip if 'Zsh is not installed' skip_shell zsh
Before 'setup_home' 'require_shell zsh'
After 'cleanup_home'

zsh_syntax() {
  for file in "$ROOT/.config/zsh/.zprofile" "$ROOT/.config/zsh/.zshrc" \
    "$ROOT"/.config/zsh/zsh.d/*.zshrc "$ROOT/.config/spaceship.zsh"; do
    zsh -n "$file" || return 1
  done
}

zsh_home() { ln -s "$ROOT/.local/share/zsh" "$HOME_DIR/.local/share/zsh"; }

zsh_compdef() {
  zsh_home
  run_isolated zsh -d -lic '(( ${+functions[compdef]} ))'
}

zsh_nested_plugins() {
  zsh_home
  run_isolated zsh -d -lic 'zsh -d -ic '\''(( ${+functions[compdef]} && ${+functions[_zsh_autosuggest_accept]} && ${+functions[_zsh_highlight]} )) && zle -l autosuggest-accept >/dev/null && bindkey -M viins | grep -q autosuggest-accept'\'''
}

zsh_without_submodules() {
  for dir in plugins/fast-syntax-highlighting plugins/zsh-autosuggestions themes/spaceship-prompt; do
    mkdir -p "$HOME_DIR/.local/share/zsh/$dir"
  done
  run_isolated zsh -d -lic exit
}

It 'parses Zsh startup, modules, and Spaceship syntax'
When run zsh_syntax
The status should be success
End

It 'defines compdef in an isolated login shell'
When run zsh_compdef
The status should be success
End

It 'loads completion, plugins, widget, and viins binding in nested interactive Zsh'
When run zsh_nested_plugins
The status should be success
End

It 'starts silently when submodule directories are empty'
When run zsh_without_submodules
The status should be success
The error should be blank
End
End
