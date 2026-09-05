#!/bin/sh
set -eu
REPO_URL="https://github.com/drts01/dotfiles"
DEST_DIR="$HOME/.local/share/dotfiles"
BASEDIR="$(cd "$(dirname "$0")" && pwd)"

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

df config core.worktree "$HOME"
df submodule update --init

"$BASEDIR/uvfile.sh"

echo "Initializing git hooks..."
# Not sure if we need to set core.bare for pre-commit hooks to function
# df config core.bare false
HOOK_PATH="$DEST_DIR/hooks/pre-commit"
if command -v prek >/dev/null 2>&1; then
    prek install --config "$BASEDIR/prek.toml" --git-dir "$DEST_DIR"
	INJECTION="export GIT_DIR=\"$HOME/.local/share/dotfiles\" GIT_WORK_TREE=\"$HOME\""
	if grep -q "INJECTION" "$HOOK_PATH"; then
		echo "Pre-commit hook already patched."
	else
		echo "Patching prek pre-commit hook..."
		NEW_HOOK=$(awk "NR==2{print \"$INJECTION\"}1" "")
		echo "$NEW_HOOK" > "$HOOK_PATH"
	fi
else
    echo "Warning: 'prek' not found. Skipping git hooks installation."
fi

echo "Dotfiles bootstrap complete."
