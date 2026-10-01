alias dotfiles='git --git-dir=$HOME/.local/share/dotfiles --work-tree=$HOME -c diff.relative=false'

if has eza; then
  alias ls='eza --across --all --git --group-directories-first'
  alias ll='ls --icons=auto --long --header'
  alias tree='eza --tree --header --icons=auto --all'
else
  alias ls='ls -FA --color=auto'
fi

has bat && alias cat='bat'
has rip && alias rm='rip'
