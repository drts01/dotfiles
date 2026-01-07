# Fast exit for non-interactive shells (e.g., bash -c, remote commands, scripts).
case "$-" in
  *i*) : ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

has() { command -v "$1" >/dev/null 2>&1; }

if [ -n "${ZSH_VERSION-}" ]; then
  _shell=zsh
else
  _shell=bash
fi
readonly _shell

for CONF in "${ZDOTDIR}"/zsh.d/*.zshrc; do
  source "${CONF}"
done
unset CONF
