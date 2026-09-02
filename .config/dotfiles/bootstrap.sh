#!/bin/sh
set -eu
REPO_URL="https://github.com/drts01/dotfiles"
DEST_DIR="$HOME/.local/share/dotfiles"

df() { git --git-dir="$DEST_DIR" --work-tree="$HOME" "$@"; }

if [ ! -d "$DEST_DIR" ]; then
    echo "Cloning bare repo..."
    git clone --bare --single-branch --depth=1 "$REPO_URL" "$DEST_DIR"
    df config --local status.showUntrackedFiles no


    echo "Checking out dotfiles..."
    if ! df checkout; then
        BACKUP_DIR="$HOME/.df-bak"
        echo "Backing up pre-existing system dotfiles to $BACKUP_DIR..."
        df checkout 2>&1 | awk '/^\s/{print $1}' | while read -r f; do
            mkdir -p "$HOME/.df-bak/$(dirname "$f")"
            mv "$HOME/$f" "$HOME/.df-bak/$f"
        done
        echo "Retry Checking out dotfiles..."
        df checkout
    fi
else
    echo "Pulling latest changes..."
    df pull origin "$(df symbolic-ref --short HEAD)"
fi

echo "Syncing submodules..."
df submodule update --init --rebase --recommend-shallow --remote --single-branch

echo "==> Initializing hooks..."
mkdir -p "$DEST_DIR/hooks"
ln -sf "$HOME/.config/dotfiles/pre-commit" "$DEST_DIR/hooks/pre-commit"

if command -v prek >/dev/null 2>&1; then
    prek install --config "$(cd "$(dirname "$0")" && pwd)/prek.toml" --git-dir "$DEST_DIR" --prepare-hooks
else
    echo "Warning: 'prek' not found. Skipping hook installation."
fi

echo "Dotfiles bootstrap complete."
