ZSH_PLUGINS="${XDG_DATA_HOME}/zsh/plugins"
ZSH_PROMPTS="${XDG_DATA_HOME}/zsh/themes"

# shellcheck disable=SC1091
{
  ! has starship && source "$ZSH_PROMPTS/spaceship-prompt/spaceship.zsh"
  source "$ZSH_PLUGINS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
}

# Atuin must be initialized after zsh-autosuggestions.
source_cache "$XDG_CACHE_HOME/shell/atuin.zsh" atuin init zsh --disable-up-arrow

# shellcheck disable=SC2034
{
    ZSH_AUTOSUGGEST_STRATEGY=(atuin history)
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555555"
    (( ${+autosuggest-accept} )) && bindkey -M viins '^[[C' autosuggest-accept  # Allow the Right Arrow key to accept suggestions in Vi Insert mode
}
