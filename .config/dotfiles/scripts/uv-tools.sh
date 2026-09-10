#!/bin/sh
set -eu
BASEDIR="${BASEDIR:-$(cd "$(dirname "$0")/.." && pwd)}"

echo "Installing uv tools"
while read -r line || [ -n "$line" ]; do
  case "$line" in '' | \#*) continue ;; esac
  # shellcheck disable=SC2086 # intentional word-splitting: "tool [--with pkgs...]"
  set -- $line
  tool=$1
  shift
  uv tool install "$tool" ${1:+--with "$@"}
done < "$BASEDIR/uvfile.txt"
