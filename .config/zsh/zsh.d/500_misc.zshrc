has starship && eval "$(starship init "$_shell")"

# if ! type z > /dev/null; then
#   for lua in lua luajit lua5.4 lua5.3 lua5.2 lua5.1; do
#     ZLUA_EXEC="$(command -v "$lua")"
#     [ -n "$ZLUA_EXEC" ] && break
#   done
# eval "$("$ZLUA_EXEC" "${XDG_DATA_HOME}/z.lua/z.lua" --init "${SHELL##*/}" enhanced once "$(type fzf &> /dev/null && echo fzf)")"
# fi

if [ -n "${RBENV_ROOT-}" ] && [ -x "${RBENV_ROOT}/bin/rbenv" ]; then
  eval "$("${RBENV_ROOT}/bin/rbenv" init - "$_shell")"
fi

has jenv && eval "$(jenv init -)"

if [ -n "${SDKMAN_DIR-}" ] && [ -r "${SDKMAN_DIR}/bin/sdkman-init.sh" ]; then
  . "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

has kubectl && {
  # Cache to avoid running `kubectl completion ...` on every startup (can be slow).
  _kube_comp_cache="${XDG_CACHE_HOME}/kubectl/completion.${_shell}"

  # zsh needs completion system initialized (compdef). If it's not ready, skip quietly.
  if [ "$_shell" != "zsh" ] || has compdef; then
    if [ ! -r "$_kube_comp_cache" ] || [ "$_kube_comp_cache" -ot "$(command -v kubectl)" ]; then # typos: ignore
      command mkdir -p "${_kube_comp_cache%/*}" 2>/dev/null || :
      kubectl completion "$_shell" >| "$_kube_comp_cache" 2>/dev/null || :
    fi
    [ -r "$_kube_comp_cache" ] && . "$_kube_comp_cache"
  fi

  unset _kube_comp_cache
}
