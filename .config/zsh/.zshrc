# Stop execution here for non-interactive tasks (prevents scp/rsync/cron errors)
# shellcheck disable=SC2317
case "$-" in
*i*) : ;;
*) return 0 2> /dev/null || exit 0 ;;
esac

zmodload zsh/parameter

# shellcheck disable=SC1090
. "$ENV"

for file in "${ZDOTDIR}"/zsh.d/*.zshrc; do
  # shellcheck disable=SC1090
  source "$file"
done
unset CONF

[[ -n $ZSH_PROFILE ]] && zprof
