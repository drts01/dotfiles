# XDG -- https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

# zsh
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
export HISTFILE="${XDG_STATE_HOME}/.zsh_history"
export HISTSIZE=20000
export SAVEHIST=20000

# Editors
export EDITOR=vi
export VISUAL=vi

# readline
export INPUTRC="${XDG_CONFIG_HOME}/inputrc"

# Screen
export SCREENRC="${XDG_CONFIG_HOME}/screenrc"

# wget
export WGETRC="${XDG_CONFIG_HOME}/wgetrc"

# Starship
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship.toml"

# Python
export IPYTHONDIR="${XDG_CONFIG_HOME}/jupyter"
export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}/jupyter"
export PIPX_HOME="${XDG_DATA_HOME}/pipx"
export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export WORKON_HOME="${XDG_DATA_HOME}/virtualenvs"

# Programing
export ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/asdfrc"
export ASDF_DIR="${XDG_DATA_HOME}/asdf"
export ASDF_DATA_DIR="${XDG_DATA_HOME}/asdf"
export NVM_DIR="${XDG_DATA_HOME}/nvm"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RBENV_ROOT="${XDG_DATA_HOME}/rbenv"
export SDKMAN_DIR="${XDG_DATA_HOME}/sdkman"

# containers / k8s
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export MINIKUBE_HOME="${XDG_DATA_HOME}/minikube"
export K9SCONFIG="${XDG_CONFIG_HOME}/k9s"
export KUBECONFIG="${XDG_CONFIG_HOME}/kubeconfig"

# Terraform
export TFENV_ROOT="${XDG_DATA_HOME}/tfenv"
export TOFUENV_ROOT="${XDG_DATA_HOME}/tofu"
export TENV_ROOT="${XDG_DATA_HOME}/tenv"

# Vagrant
export VAGRANT_HOME="${XDG_DATA_HOME}/vagrant"
export VAGRANT_ALIAS_FILE="${XDG_DATA_HOME}/vagrant/aliases"

export _ZL_DATA="${XDG_DATA_HOME}/zlua"

