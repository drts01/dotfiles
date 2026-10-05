# shellcheck disable=SC2148

path_add "$HOME/.bin"
path_add "$HOME/.local/bin"

# shellcheck disable=SC2154
has mise && eval "$(mise activate "${_shell}" --shims)"

set -o vi    # Enable vim bindings
KEYTIMEOUT=1 # Reduces escape key delay for switching modes

if has hx; then
  VISUAL="hx"
elif has nvim; then
  VISUAL="nvim"
elif has vim; then
  VISUAL="vim"
else VISUAL="vi"; fi

EDITOR="$VISUAL"

has bat && export PAGER="bat --plain"

if has less; then
  [ -z "$PAGER" ] && PAGER='less'
  export LESSCHARSET="UTF-8" LESSHISTFILE='-' LESS=-FXgiMRSwz-4 PAGER
fi

export KEYTIMEOUT VISUAL EDITOR
