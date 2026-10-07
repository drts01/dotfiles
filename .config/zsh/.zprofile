[[ -n $ZSH_PROFILE ]] && zmodload zsh/zprof

. "$HOME/.profile"

if [[ -z $HOMEBREW_PREFIX ]]; then
  if [[ -d /opt/homebrew ]]; then
    HOMEBREW_PREFIX=/opt/homebrew
  elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
    HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
  elif [[ -d /usr/local/Homebrew ]]; then
    HOMEBREW_PREFIX=/usr/local
  fi
fi

if [[ -n $HOMEBREW_PREFIX ]]; then
  HOMEBREW_REPOSITORY=$HOMEBREW_PREFIX/Homebrew
  [[ $HOMEBREW_PREFIX == /opt/homebrew ]] && HOMEBREW_REPOSITORY=$HOMEBREW_PREFIX
  HOMEBREW_CELLAR=$HOMEBREW_PREFIX/Cellar
  path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" $path)
  typeset -U path
  FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"
  export HOMEBREW_PREFIX HOMEBREW_REPOSITORY HOMEBREW_CELLAR
  export HOMEBREW_AUTO_UPDATE_SECS=86400 HOMEBREW_NO_ANALYTICS=1
fi
