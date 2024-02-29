type starship &> /dev/null && eval "$(starship init zsh)"

test -f /usr/share/fzf/key-bindings.zsh && source /usr/share/fzf/key-bindings.zsh

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[ -s "${PYENV_ROOT}/bin/pyenv" ] && eval "$("${PYENV_ROOT}/bin/pyenv" init -)"
[ -s "${RBENV_ROOT}/bin/rbenv" ] && eval "$(${RBENV_ROOT}/bin/rbenv init - zsh)"

type jenv &> /dev/null && eval "$(jenv init -)"
[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

type tfenv &> /dev/null && export TFENV_AUTO_INSTALL=true
type kubectl &> /dev/null && source <(kubectl completion zsh)
type direnv &> /dev/null && eval "$(direnv hook zsh)"

[ -f "${ASDF_DIR}/asdf.sh" ] && . "${ASDF_DIR}/asdf.sh"

