HB_ARM_PREFIX='/opt/homebrew/bin/brew'  # Default path for ARM
if command -v brew > /dev/null; then
  eval "$(brew shellenv)"
elif [ -x "${HB_ARM_PREFIX}" ]; then
  eval "$(${HB_ARM_PREFIX} shellenv)"
fi

if [ -n "${HOMEBREW_PREFIX}" ]; then
  # Autocomplete
  FPATH="${HOMEBREW}/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit

  # fzf
  [[ $- == *i* ]] && source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" 2> /dev/null
  command -v fzf > /dev/null && source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
fi
