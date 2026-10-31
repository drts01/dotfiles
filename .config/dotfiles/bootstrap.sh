#!/bin/sh
# Remote entrypoint:
#   curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
# Set SKIP_MISE_INSTALL=1 to deploy the dotfiles with git only.

set -eu

RAW_URL="https://raw.githubusercontent.com/drts01/dotfiles/trunk"
SKIP_MISE_INSTALL="${SKIP_MISE_INSTALL:-}"

# Wrapped in main so `curl | sh` never executes a partially downloaded script.
main() {
  if command -v curl > /dev/null 2>&1; then
    fetch() { curl -LsSf --retry 3 "$1"; }
  elif command -v wget > /dev/null 2>&1; then
    # BusyBox wget rejects --tries and --no-hsts.
    fetch() { wget -qO- "$1"; }
  else
    echo "ERROR: Neither curl nor wget found." >&2
    exit 1
  fi

  if ! command -v git > /dev/null 2>&1; then
    echo "ERROR: git is required." >&2
    exit 1
  fi

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  trap 'exit 1' HUP INT TERM

  # mise is optional: an install failure must not block deploying the dotfiles.
  if [ -z "$SKIP_MISE_INSTALL" ] && ! command -v mise > /dev/null 2>&1; then
    echo "Installing mise..."
    if fetch https://mise.run > "$TMP_DIR/mise-install.sh" &&
      MISE_INSTALL_SKIP_IF_EXISTS=1 sh "$TMP_DIR/mise-install.sh"; then
      PATH="$(dirname "${MISE_INSTALL_PATH:-$HOME/.local/bin/mise}"):$PATH"
      export PATH
    else
      echo "Warning: mise installation failed; continuing without mise." >&2
    fi
  fi

  # Download to a file: in `fetch | sh` a failed fetch is masked by sh exiting 0.
  fetch "$RAW_URL/.config/dotfiles/mise-tasks/bootstrap.sh" > "$TMP_DIR/bootstrap.sh"
  sh "$TMP_DIR/bootstrap.sh"
}

main "$@"
