# shellcheck shell=bash

case $- in
  *i*)
    # shellcheck source=/dev/null
    . "$HOME/.bashrc"
    ;;
esac
