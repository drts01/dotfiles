#!/bin/sh
set -eu

BASEDIR="${BASEDIR:-$HOME/.config/dotfiles}"

# Reuse the deploy script so updates take the same tested path as fresh installs:
# fast-forward pull, submodule sync from $HOME, and hook installation.
sh "$BASEDIR/mise-tasks/bootstrap.sh"

echo "Update from global mise configuration..."
mise --cd "$HOME/.config/mise" bootstrap
