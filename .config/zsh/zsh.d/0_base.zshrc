#History
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# zsh
export HISTFILE="${XDG_STATE_HOME}/.zsh_history"
export HISTSIZE=20000
export SAVEHIST=20000

# readline
export INPUTRC="${XDG_CONFIG_HOME}/inputrc"
export KEYTIMEOUT=1

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
