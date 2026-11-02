# Stop execution here for non-interactive tasks (prevents scp/rsync/cron errors)
# shellcheck disable=SC2317
case "$-" in
  *i*) : ;;
  *) return 0 2> /dev/null || exit 0 ;;
esac

zmodload zsh/parameter

if [[ -n ${HOMEBREW_PREFIX-} ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" "${fpath[@]}")
  typeset -U fpath
fi

ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"
[[ -d ${ZSH_COMPDUMP:h} ]] || mkdir -p "${ZSH_COMPDUMP:h}"
autoload -Uz compinit
_zcomp_stale=("$ZSH_COMPDUMP"(N.mh+24))
if [[ -s $ZSH_COMPDUMP ]] && ((! ${#_zcomp_stale})); then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -i -d "$ZSH_COMPDUMP"
  zcompile "$ZSH_COMPDUMP"
fi
unset _zcomp_stale

# shellcheck disable=SC1090
. "$ENV"

for file in "${ZDOTDIR}"/zsh.d/*.zshrc; do
  # shellcheck disable=SC1090
  source "$file"
done

if [[ -n ${ZSH_PROFILE-} ]]; then
  zprof
fi
