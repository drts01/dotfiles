type starship &> /dev/null && eval "$(starship init zsh)"

type "${PYENV_ROOT}/bin/pyenv" &> /dev/null && eval "$("${PYENV_ROOT}/bin/pyenv" init -)"

type rbenv &> /dev/null && eval "$(rbenv init - zsh)"

if type tfenv &> /dev/null; then
  export TFENV_AUTO_INSTALL=true
fi

type jenv &> /dev/null && eval "$(jenv init -)"

type kubectl &> /dev/null && source <(kubectl completion zsh)
