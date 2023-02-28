type starship &> /dev/null && eval "$(starship init zsh)"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

type "${PYENV_ROOT}/bin/pyenv" &> /dev/null && eval "$("${PYENV_ROOT}/bin/pyenv" init -)"

type rbenv &> /dev/null && eval "$(rbenv init - zsh)"

if type tfenv &> /dev/null; then
  export TFENV_AUTO_INSTALL=true
fi

type jenv &> /dev/null && eval "$(jenv init -)"

type kubectl &> /dev/null && source <(kubectl completion zsh)

[ -f "${RBENV_ROOT}/bin/rbenv" ] && eval "$(${RBENV_ROOT}/bin/rbenv init - zsh)"
[ -f "${ASDF_DIR}/asdf.sh" ] && . "${ASDF_DIR}/asdf.sh"

