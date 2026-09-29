alias dotfiles='git --git-dir=$HOME/.local/share/dotfiles --work-tree=$HOME -c diff.relative=false'

if has eza; then
  alias ls="eza --icons=always --git --group-directories-first"
  alias ll="eza -la --icons=always --git --group-directories-first"
else
  alias ls='ls -FA --color=auto'
fi

has bat && alias cat="bat --style=plain"
has rip && alias rm="rip"
