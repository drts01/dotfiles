# shellcheck shell=bash

# shellcheck source=/dev/null
. "$HOME/.profile"

case $- in
  *i*)
    # shellcheck source=/dev/null
    . "$HOME/.bashrc"
    ;;
esac
