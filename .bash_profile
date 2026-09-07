# shellcheck shell=bash
# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Make vim the default editor
export EDITOR="vim"

# Ignore duplicate commands in the history
export HISTCONTROL=ignoredups

# Don't clear the screen after quitting a manual page
export MANPAGER="less -X"

# shellcheck source=/dev/null
[ -f "$(brew --prefix)/etc/bash_completion" ] && . "$(brew --prefix)/etc/bash_completion"
# shellcheck source=/dev/null
. "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export PATH=/Users/carlos.meza/.local/bin:$PATH

##
# Your previous /Users/carlos.meza/.bash_profile file was backed up as /Users/carlos.meza/.bash_profile.macports-saved_2019-02-20_at_09:28:58
##

# MacPorts Installer addition on 2019-02-20_at_09:28:58: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

# shellcheck source=/dev/null
. "$(command -v aws_bash_completer)"
