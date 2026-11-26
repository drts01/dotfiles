# Set DOTFILES_OSC133=0 before startup when another integration emits the markers.
[[ ${DOTFILES_OSC133-1} != 0 ]] || return 0
# Rio loads its native integration before the user's rc files.
((! ${+_rio_state})) || return 0

# Zellij consumes the markers even when its host terminal (such as Alacritty) cannot.
if [[ -n ${ZELLIJ-} || ${TERM_PROGRAM-} == rio || ${TERM_PROGRAM-} == Ghostty || ${TERM_PROGRAM-} == WezTerm || ${TERM_PROGRAM-} == iTerm.app ]]; then
  _osc133_precmd() {
    local exit_status=$?
    if [[ ${_osc133_command_running-0} == 1 ]]; then
      printf '\e]133;D;%s\a' "$exit_status"
      _osc133_command_running=0
    fi
    printf '\e]133;A\a'
  }

  _osc133_preexec() {
    printf '\e]133;C\a'
    _osc133_command_running=1
  }

  _inject_osc133_b() {
    # Preserve prompt width when adding the marker after prompt framework hooks.
    local marker=$'%{\e]133;B\a%}'
    [[ ${PROMPT-} == *"$marker" ]] || PROMPT+="$marker"
    return 0
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _osc133_precmd
  add-zsh-hook preexec _osc133_preexec
  add-zsh-hook precmd _inject_osc133_b
fi
