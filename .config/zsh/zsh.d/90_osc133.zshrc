# Alacritty does not support OSC 133: https://github.com/alacritty/alacritty/issues/5850
if [[ -n ${ZELLIJ-} || ${TERM_PROGRAM-} == Ghostty || ${TERM_PROGRAM-} == WezTerm || ${TERM_PROGRAM-} == iTerm.app ]]; then
  _osc133_precmd() {
    printf '\e]133;D;%s\a\e]133;A\a' "$?"
  }

  _osc133_preexec() {
    printf '\e]133;C\a'
  }

  _inject_osc133_b() {
    # Preserve prompt width when adding the marker after prompt framework hooks.
    PS1="${PROMPT-}%{\e]133;B\a%}"
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _osc133_precmd
  add-zsh-hook preexec _osc133_preexec
  add-zsh-hook precmd _inject_osc133_b
fi
