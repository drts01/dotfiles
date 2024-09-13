type starship &> /dev/null && eval "$(starship init zsh)"

test -f /usr/share/fzf/key-bindings.zsh && source /usr/share/fzf/key-bindings.zsh

type zoxide > /dev/null && eval "$(zoxide init "${SHELL##*/}")"

# if ! type z > /dev/null; then
#   for lua in lua luajit lua5.4 lua5.3 lua5.2 lua5.1; do
#     ZLUA_EXEC="$(command -v "$lua")"
#     [ -n "$ZLUA_EXEC" ] && break
#   done
# eval "$("$ZLUA_EXEC" "${XDG_DATA_HOME}/z.lua/z.lua" --init "${SHELL##*/}" enhanced once "$(type fzf &> /dev/null && echo fzf)")"
# fi

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

