#!/bin/sh

set -eu

UVFILE="${UVFILE:-$(cd "$(dirname "$0")" && pwd)/uvfile.txt}"
UV_INSTALL_URL=${UV_INSTALL_URL:-https://astral.sh/uv/install.sh}

echo 'Installing uv'
if command -v curl >/dev/null 2>&1; then
    curl -LsSf "$UV_INSTALL_URL" | sh
elif command -v wget >/dev/null 2>&1; then
    wget --no-hsts -qO- "$UV_INSTALL_URL" | sh
else
    echo "ERROR: Could not install uv. Neither curl nor wget found." >&2
    exit 1
fi

echo 'Installing uv tools'
while read -r line || [ -n "$line" ]; do
  case "$line" in ''|\#*) continue ;; esac
  set -- "$line"
  tool=$1; shift
  uv tool install "$tool" ${1:+--with "$@"}
done < "$UVFILE"
