# Fuzzy search
# Must go before Atuin and Zoxide
if has sk; then
    export FZF_DEFAULT_COMMAND="sk"
    # export SKIM_DEFAULT_OPTIONS="--height 40% --layout=reverse --inline-info --color=light"
    source <(sk "--shell $_shell")
    alias fzf="sk"

elif has fzf; then
    # Fallback to standard fzf
    if has fd; then
      # Set fzf to use 'fd' instead of the slow native 'find' command
      export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    else
      # Need to verify if we need to run script ourselves
      _fzf_key_bindings="/usr/share/fzf/key-bindings.${_shell}"
      [ -r "$_fzf_key_bindings" ] && . "$_fzf_key_bindings"
      unset _fzf_key_bindings
    fi

    source <(fzf "--$_shell" )
fi

# has atuin && eval "$(atuin init "$_shell")"
has zoxide && eval "$(zoxide init "$_shell")"
