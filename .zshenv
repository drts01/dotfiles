# XDG -- https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

# zsh
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export HISTSIZE=10000
export SAVEHIST=10000

# Editors
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

# Less
export LESSCHARSET="UTF-8"
export LESSHISTFILE='-'
export LESS='-F -X -g -i -M -R -S -w -z-4'

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

# containers / k8s
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export MINIKUBE_HOME="${XDG_DATA_HOME}/minikube"
export K9SCONFIG="${XDG_CONFIG_HOME}/k9s"
export KUBECONFIG="${XDG_CONFIG_HOME}/kubeconfig"

# Vagrant
export VAGRANT_HOME="${XDG_DATA_HOME}/vagrant"
export VAGRANT_ALIAS_FILE="${XDG_DATA_HOME}/vagrant/aliases"
