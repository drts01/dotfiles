# shellcheck shell=sh

if has sk; then
  export FZF_DEFAULT_COMMAND=sk
  alias fzf=sk
elif has fzf && has fd; then
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# shellcheck disable=SC2154
case $_shell in
bash | zsh)
  if has sk; then
    source_cache "$XDG_CACHE_HOME/shell/sk.$_shell" sk --shell "$_shell"
  elif has fzf && has fd; then
    _fzf_key_bindings="/usr/share/fzf/key-bindings.$_shell"
    # shellcheck disable=SC1090
    [ -r "$_fzf_key_bindings" ] && . "$_fzf_key_bindings"
    unset _fzf_key_bindings
    source_cache "$XDG_CACHE_HOME/shell/fzf.$_shell" fzf --shell "$_shell"
  fi
  [ "$_shell" = zsh ] || source_cache "$XDG_CACHE_HOME/shell/atuin.bash" atuin init bash --disable-up-arrow
  source_cache "$XDG_CACHE_HOME/shell/zoxide.$_shell" zoxide init "$_shell"
  ;;
sh)
  source_cache "$XDG_CACHE_HOME/shell/zoxide.posix" zoxide init posix
  ;;
esac
