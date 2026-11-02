# shellcheck shell=sh

[ -d /opt/local/sbin ] && path_add /opt/local/sbin
[ -d /opt/local/bin ] && path_add /opt/local/bin
path_add "$HOME/.bin"
path_add "$HOME/.local/bin"

MISE_DATA_DIR="${MISE_DATA_DIR:-$XDG_DATA_HOME/mise}"
path_add "$MISE_DATA_DIR/shims"
export MISE_DATA_DIR

export INPUTRC="$XDG_CONFIG_HOME/inputrc"
export SCREENRC="$XDG_CONFIG_HOME/screenrc"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
export IPYTHONDIR="$XDG_CONFIG_HOME/jupyter" JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export PIPX_HOME="$XDG_DATA_HOME/pipx" PYENV_ROOT="$XDG_DATA_HOME/pyenv" WORKON_HOME="$XDG_DATA_HOME/virtualenvs"
export ASDF_CONFIG_FILE="$XDG_CONFIG_HOME/asdfrc" ASDF_DIR="$XDG_DATA_HOME/asdf" ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"
export NVM_DIR="$XDG_DATA_HOME/nvm" CARGO_HOME="$XDG_DATA_HOME/cargo" RBENV_ROOT="$XDG_DATA_HOME/rbenv" SDKMAN_DIR="$XDG_DATA_HOME/sdkman"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker" MINIKUBE_HOME="$XDG_DATA_HOME/minikube" K9SCONFIG="$XDG_CONFIG_HOME/k9s" KUBECONFIG="$XDG_CONFIG_HOME/kubeconfig"
export TFENV_ROOT="$XDG_DATA_HOME/tfenv" TOFUENV_ROOT="$XDG_DATA_HOME/tofu" TENV_ROOT="$XDG_DATA_HOME/tenv"
export VAGRANT_HOME="$XDG_DATA_HOME/vagrant" VAGRANT_ALIAS_FILE="$XDG_DATA_HOME/vagrant/aliases" _ZL_DATA="$XDG_DATA_HOME/zlua"

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

export VISUAL EDITOR
