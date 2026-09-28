#!/bin/sh

set -eu

SKIP_MISE_INSTALL=""
FETCH=""

if command -v curl > /dev/null 2>&1; then
  FETCH="curl -LsSf --retry 3"
elif command -v wget > /dev/null 2>&1; then
  FETCH="wget --no-hsts --tries=3 -qO-"
else
  echo "ERROR: Could not install mise. Neither curl nor wget found." >&2
  exit 1
fi

if [ -n "$SKIP_MISE_INSTALL" ] && ! command -v mise > /dev/null 2>&1; then
  echo 'Installing mise...'
  $FETCH https://mise.run | MISE_INSTALL_SKIP_IF_EXISTS=1 sh
fi

$FETCH https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh

echo "Dotfiles bootstrap complete."
