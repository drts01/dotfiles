# Fuzzy search
# Must go before Atuin and Zoxide
if has sk; then
    export FZF_DEFAULT_COMMAND=sk
    source_cache "$XDG_CACHE_HOME/shell/sk.$_shell" sk --shell "$_shell"
    alias fzf=sk

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

    source_cache "$XDG_CACHE_HOME/shell/fzf.$_shell" fzf --shell "$_shell"
fi

[ "$_shell" = zsh ] || source_cache "$XDG_CACHE_HOME/shell/atuin.$_shell" atuin init "$_shell" --disable-up-arrow
source_cache "$XDG_CACHE_HOME/shell/zoxide.$_shell" zoxide init "$_shell"
