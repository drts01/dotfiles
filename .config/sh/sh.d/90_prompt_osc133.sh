# shellcheck shell=bash
# TODO: Fix BASH section to be POSIX compliant

if [ -z "$PS1" ]; then
  if [ -n "$USER" ] && [ -n "$HOSTNAME" ]; then
    PS1="$USER@$HOSTNAME:\${PWD##*/} \$ "
  else
    PS1='$ '
  fi
fi

# OSC 133 Terminal Prompt Integration Script
# Alacritty does not support OSC 133: https://github.com/alacritty/alacritty/issues/5850
if [ -n "$ZELLIJ" ] || [ "$TERM_PROGRAM" = "Ghostty" ] || [ "$TERM_PROGRAM" = "WezTerm" ] || [ "$TERM_PROGRAM" = "iTerm.app" ]; then
  if [ -n "$ZSH_VERSION" ]; then
    # Report Command End (D) with exit status, then immediately start Prompt (A)
    _osc133_precmd() {
      printf "\e]133;D;%s\a\e]133;A\a" "$?"
    }

    # Report Command Start (C)
    _osc133_preexec() {
      printf "\e]133;C\a"
    }

    # Inject the B marker dynamically right before rendering the prompt
    _inject_osc133_b() {
      # Ensure %{ %} wraps the sequence so Zsh doesn't break cursor alignment.
      # We append it to PS1 dynamically instead of modifying the global PROMPT variable.
      # shellcheck disable=SC2025  # Okay in ZSH
      PS1="$PROMPT%{\e]133;B\a%}"
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _osc133_precmd
    add-zsh-hook preexec _osc133_preexec
    add-zsh-hook precmd _inject_osc133_b # We append this last to the hook array so it runs after prompt frameworks like Starship

  elif [ -n "$BASH_VERSION" ]; then
    # Use PS0 to safely catch command execution start without using DEBUG traps
    export PS0='\[\e]133;C\]'

    _bash_osc133_prompt() {
      local exit_status=$?
      # Signal command ended (D) and new prompt starting (A)
      printf "\e]133;D;%s\a\e]133;A\a" "$exit_status"
    }

    # Safely append our hook to PROMPT_COMMAND without risking an infinite evaluation loop
    if [[ ! $PROMPT_COMMAND =~ _bash_osc133_prompt ]]; then
      PROMPT_COMMAND="_bash_osc133_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    fi

    # Inject B marker cleanly into the live PS1 string evaluation
    # This places it at the very end of your final rendered Bash prompt layout
    if [[ $PS1 != *"133;B"* ]]; then
      export PS1="$PS1"'\[\e]133;B\]'
    fi

  else
    _osc133_a=$(printf "\033]133;A\033\\")
    _osc133_b=$(printf "\033]133;B\033\\")

    if [ -n "$STARSHIP_SHELL" ]; then
      PS1="${_osc133_a}\$(starship prompt)${_osc133_b}"
    else
      PS1="${_osc133_a}${PS1:-$ }${_osc133_b}"
    fi
    export PS1

  fi

fi
