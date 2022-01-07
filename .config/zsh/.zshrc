for CONF in "${ZDOTDIR}"/zsh.d/*.zshrc; do
  source "${CONF}"
done
unset CONF
