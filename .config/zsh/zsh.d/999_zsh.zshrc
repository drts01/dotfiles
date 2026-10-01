ZSH_PLUGINS="${XDG_DATA_HOME}/zsh/plugins"
ZSH_PROMPTS="${XDG_DATA_HOME}/zsh/themes"

! has starship && source "$ZSH_PROMPTS/spaceship-prompt/spaceship.zsh"
source "$ZSH_PLUGINS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGINS/z.lua/z.lua.plugin.zsh"

# Atuin must be initialized after zsh-autosuggestions
if (( ${+zvm_after_init_commands} )); then
    # If the zsh-vi-mode plugin is loaded
    # shellcheck disable=SC2016
    zvm_after_init_commands+=('eval "$(atuin init zsh)"')
else
    # Fallback to initializing Atuin
    eval "$(atuin init zsh)"
fi

# shellcheck disable=SC2034
ZSH_AUTOSUGGEST_STRATEGY=(atuin history)
bindkey -M viins '^[[C' autosuggest-accept  # Allow the Right Arrow key to accept suggestions in Vi Insert mode
