ZSH_PLUGINS="${XDG_DATA_HOME}/zsh/plugins"
ZSH_PROMPTS="${XDG_DATA_HOME}/zsh/themes"

# shellcheck disable=SC1091
{
    ! has starship && source "$ZSH_PROMPTS/spaceship-prompt/spaceship.zsh"
    source "$ZSH_PLUGINS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
    source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
    source "$ZSH_PLUGINS/z.lua/z.lua.plugin.zsh"
}

# Atuin must be initialized after zsh-autosuggestions
if (( ${+zvm_after_init_commands} )); then
    # If the zsh-vi-mode plugin is loaded
    # shellcheck disable=SC2016
    zvm_after_init_commands+=('eval "$(atuin init zsh --disable-up-arrow)"')
else
    # Fallback to initializing Atuin
    eval "$(atuin init zsh --disable-up-arrow)"
fi

# shellcheck disable=SC2034
{
    ZSH_AUTOSUGGEST_STRATEGY=(atuin history)
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555555"
    bindkey -M viins '^[[C' autosuggest-accept  # Allow the Right Arrow key to accept suggestions in Vi Insert mode
}
