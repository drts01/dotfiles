#!/bin/sh
# Deploy dotfiles into $HOME from a bare repo. Requires only git and a POSIX shell;
# mise-managed setup runs afterwards only when mise is available.

set -eu

REPO_URL="${REPO_URL:-https://github.com/drts01/dotfiles}"
DEST_DIR="${DEST_DIR:-$HOME/.local/share/dotfiles}"
BASEDIR="$HOME/.config/dotfiles"
BACKUP_DIR="$HOME/.df-bak"

df() { git --git-dir="$DEST_DIR" --work-tree="$HOME" "$@"; }

if ! command -v git > /dev/null 2>&1; then
  echo "ERROR: git is required." >&2
  exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
  echo "Cloning bare repo..."
  git clone --bare --single-branch --depth=1 "$REPO_URL" "$DEST_DIR"
fi

df config --local status.showUntrackedFiles no

# `|| true`: under set -e a detached HEAD would otherwise abort the script here.
BRANCH="$(df symbolic-ref -q --short HEAD || true)"

# Bare clones get no fetch refspec, so origin/<branch> would never update.
if [ -n "$BRANCH" ] && ! df config --get remote.origin.fetch > /dev/null; then
  df config --local remote.origin.fetch "+refs/heads/$BRANCH:refs/remotes/origin/$BRANCH"
fi

# A bare repo has no index until the first checkout. Keying on the index instead of
# DEST_DIR resumes interrupted installs and supports manually cloned bare repos.
if [ ! -f "$DEST_DIR/index" ]; then
  echo "Checking out dotfiles..."
  if ! df checkout > /dev/null 2>&1; then
    echo "Backing up pre-existing dotfiles to $BACKUP_DIR..."
    TAB="$(printf '\t')"
    # Walk tracked blobs instead of parsing checkout errors (localized, and
    # `read` strips the leading tab that marks conflicting paths).
    df -c core.quotePath=false ls-tree -r HEAD | while IFS="$TAB" read -r meta f; do
      case "$meta" in
      *" blob "*) ;;
      *) continue ;;
      esac
      if [ -e "$HOME/$f" ] || [ -L "$HOME/$f" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$f")"
        mv "$HOME/$f" "$BACKUP_DIR/$f"
      fi
    done

    echo "Retry checking out dotfiles..."
    df checkout
  fi
elif [ -n "$BRANCH" ]; then
  echo "Pulling latest changes..."
  df pull --ff-only origin "$BRANCH"
else
  echo "Warning: HEAD is detached; skipping pull." >&2
fi

echo "Syncing submodules..."
df config core.worktree "$HOME"
# git-submodule requires the cwd to be inside the work tree.
(cd "$HOME" && df submodule update --init)

echo "Running post-clone setup..."
if command -v mise > /dev/null 2>&1; then
  # A fresh machine has not trusted this config; mise refuses to load it otherwise.
  mise trust "$BASEDIR/mise.toml"
  mise --cd "$BASEDIR" task run install-hooks
else
  echo "mise not found; skipping mise-managed tools."
  (cd "$BASEDIR" && sh ./mise-tasks/install-hooks.sh)
fi

echo "Dotfiles bootstrap complete."
