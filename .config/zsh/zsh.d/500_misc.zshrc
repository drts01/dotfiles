type starship &> /dev/null && eval "$(starship init zsh)"

type pyenv &> /dev/null
if [ $? -eq 0 ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

type rbenv &> /dev/null && eval "$(rbenv init - zsh)"

type tfenv &> /dev/null
if [ $? -eq 0 ]; then
  TFENV_AUTO_INSTALL=true
fi

type jenv &> /dev/null && eval "$(jenv init -)"
type kubectl &> /dev/null && source <(kubectl completion zsh)
