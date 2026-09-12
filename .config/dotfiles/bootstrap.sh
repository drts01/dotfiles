#!/bin/sh
set -eu
REPO_URL="https://github.com/drts01/dotfiles"
DEST_DIR="$HOME/.local/share/dotfiles"
BASEDIR="$HOME/.config/dotfiles"

df() { git --git-dir="$DEST_DIR" --work-tree="$HOME" "$@"; }

if [ ! -d "$DEST_DIR" ]; then
  echo "Cloning bare repo..."
  git clone --bare --single-branch --depth=1 "$REPO_URL" "$DEST_DIR"
  df config --local status.showUntrackedFiles no

  echo "Checking out dotfiles..."
  if ! df checkout 2>&1; then
    BACKUP_DIR="$HOME/.df-bak"
    echo "Backing up pre-existing system dotfiles to $BACKUP_DIR..."
    df checkout 2>&1 | while read -r line; do
      TAB=$(printf '\t')
      case "$line" in
      [" $TAB"]*) # Match lines starting with spaces or tabs (conflicting files)
        f=$(echo "$line" | sed 's/^[[:space:]]*//')
        if [ -f "$HOME/$f" ] || [ -L "$HOME/$f" ]; then
          mkdir -p "$BACKUP_DIR/$(dirname "$f")"
          mv "$HOME/$f" "$BACKUP_DIR/$f"
        fi
        ;;
      esac
    done

    echo "Retry Checking out dotfiles..."
    df checkout
  fi
else
  echo "Pulling latest changes..."
  BRANCH="$(df symbolic-ref -q --short HEAD)"
  if [ -n "$BRANCH" ]; then
    df pull origin "$BRANCH"
  else
    echo "Warning: HEAD is detached; skipping pull." >&2
  fi
fi

echo "Syncing submodules..."
df config core.worktree "$HOME"
df submodule update --init

if ! command -v mise > /dev/null 2>&1; then
  echo 'Installing mise...'
  if command -v curl > /dev/null 2>&1; then
    curl -LsSf --retry 3 https://mise.run | MISE_INSTALL_SKIP_IF_EXISTS=1 sh
  elif command -v wget > /dev/null 2>&1; then
    wget --no-hsts --tries=3 -qO- https://mise.run | MISE_INSTALL_SKIP_IF_EXISTS=1 sh
  else
    echo "ERROR: Could not install mise. Neither curl nor wget found." >&2
    exit 1
  fi
fi

echo "Running post-clone setup..."
mise run --cd "$BASEDIR" bootstrap

echo "Dotfiles bootstrap complete."
