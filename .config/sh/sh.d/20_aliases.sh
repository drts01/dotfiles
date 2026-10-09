# shellcheck shell=sh
alias dotfiles='git --git-dir=$HOME/.local/share/dotfiles --work-tree=$HOME -c diff.relative=false'

if has eza; then
  ls() {
    eza_icons=""
    for arg in "$@"; do
      case "$arg" in
      *-[a-zA-Z0-9]*[l1]* | "--long" | "-l" | "-1")
        eza_icons="--icons=auto"
        break
        ;;
      esac
    done

    eza --across --all --git --group-directories-first $eza_icons "$@"
    unset eza_icons arg
  }

  ll() { ls --long --header "$@"; }
  tree() { eza --tree --header --all --icons "$@"; }
else
  alias ls='ls -FA --color=auto'
fi

has bat && alias cat='bat'
has rip && alias rm='rip'

has prek && alias pre-commit='prek'
