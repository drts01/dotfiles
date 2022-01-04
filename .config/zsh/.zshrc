for CONF in "${ZDOTDIR}"/*.zsh; do
  source "${CONF}"
done
unset CONF
