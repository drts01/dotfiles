# shellcheck shell=bash
#
# shellcheck disable=SC2154
case $_shell in
bash | zsh)
  source_cache "$XDG_CACHE_HOME/shell/starship.$_shell" starship init "$_shell"
  [ -x "${RBENV_ROOT-}/bin/rbenv" ] && source_cache "$XDG_CACHE_HOME/shell/rbenv.$_shell" "$RBENV_ROOT/bin/rbenv" init - "$_shell"
  source_cache "$XDG_CACHE_HOME/shell/jenv.$_shell" jenv init -

  if [ -r "${SDKMAN_DIR-}/bin/sdkman-init.sh" ]; then
    sdk() {
      unset -f sdk
      # shellcheck source=/dev/null
      . "$SDKMAN_DIR/bin/sdkman-init.sh"
      sdk "$@"
    }
  fi

  if has aws_completer; then
    export AWS_CLI_AUTO_PROMPT=on-partial
    [ "$_shell" = zsh ] && autoload bashcompinit && bashcompinit
    complete -C aws_completer aws
  fi

  if has kubectl && { [ "$_shell" != zsh ] || command -v compdef > /dev/null 2>&1; }; then
    _kube_comp_cache="$XDG_CACHE_HOME/kubectl/completion.$_shell"
    if [ ! -r "$_kube_comp_cache" ] || [ "$_kube_comp_cache" -ot "$(command -v kubectl)" ]; then
      mkdir -p "${_kube_comp_cache%/*}" 2> /dev/null || :
      kubectl completion "$_shell" > "$_kube_comp_cache" 2> /dev/null || :
    fi
    # shellcheck disable=SC1090
    [ -r "$_kube_comp_cache" ] && . "$_kube_comp_cache"
    unset _kube_comp_cache
  fi
  ;;
esac

source_cache "$XDG_CACHE_HOME/shell/mise.$_shell" mise activate "$_shell"
