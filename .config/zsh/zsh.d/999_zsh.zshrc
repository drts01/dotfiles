ZSH_PLUGINS="${XDG_DATA_HOME}/zsh/plugins"
ZSH_PROMPTS="${XDG_DATA_HOME}/zsh/themes"

! type starship &> /dev/null && source "$ZSH_PROMPTS/spaceship-prompt/spaceship.zsh"
source "$ZSH_PLUGINS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGINS/z.lua/z.lua.plugin.zsh"

# autoload -Uz compinit; compinit


