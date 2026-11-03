#!/bin/sh
# Deploy dotfiles into $HOME from a bare repo. Requires only git and a POSIX shell;
# mise-managed setup runs afterwards only when mise is available.

set -eu

REPO_URL="${REPO_URL:-https://github.com/drts01/dotfiles}"
DEST_DIR="${DEST_DIR:-$HOME/.local/share/dotfiles}"
BASEDIR="$HOME/.config/dotfiles"
BACKUP_DIR="$HOME/.df-bak"
DOTFILES_SUBMODULES="${DOTFILES_SUBMODULES-auto}"
DOTFILES_SKIP_SUBMODULES="${DOTFILES_SKIP_SUBMODULES-}"

# Validate both selections before cloning or changing the working tree.
parse_groups() {
  value=$1
  variable=$2
  case "$value" in
    '' | ,* | *, | *,,* | auto | all | none)
      printf 'ERROR: %s must be a comma-separated list of zsh,nvim,lua,docs.\n' "$variable" >&2
      exit 1
      ;;
  esac
  parsed=' '
  remaining=$value,
  while [ -n "$remaining" ]; do
    group=${remaining%%,*}
    remaining=${remaining#*,}
    case "$group" in
      zsh | nvim | lua | docs) ;;
      *)
        printf 'ERROR: %s must be a comma-separated list of zsh,nvim,lua,docs.\n' "$variable" >&2
        exit 1
        ;;
    esac
    case "$parsed" in
      *" $group "*) ;;
      *) parsed="$parsed$group " ;;
    esac
  done
}

case "$DOTFILES_SUBMODULES" in
  auto | all) groups=' zsh nvim lua docs ' ;;
  none) groups=' ' ;;
  *)
    parse_groups "$DOTFILES_SUBMODULES" DOTFILES_SUBMODULES
    groups=$parsed
    ;;
esac
case "$DOTFILES_SKIP_SUBMODULES" in
  '') skips=' ' ;;
  all) skips=' zsh nvim lua docs ' ;;
  *)
    parse_groups "$DOTFILES_SKIP_SUBMODULES" DOTFILES_SKIP_SUBMODULES
    skips=$parsed
    ;;
esac

df() { git --git-dir="$DEST_DIR" --work-tree="$HOME" "$@"; }

if ! command -v git > /dev/null 2>&1; then
  echo "ERROR: git is required." >&2
  exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
  echo "Cloning bare repo..."
  git clone --bare --single-branch --depth=1 "$REPO_URL" "$DEST_DIR"
fi

# Remove the legacy setting before reading the bare repo through the df wrapper.
# --file avoids Git's core.bare/core.worktree warning during migration.
if git config --file "$DEST_DIR/config" --get core.worktree > /dev/null; then
  git config --file "$DEST_DIR/config" --unset-all core.worktree
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

# Git submodule needs the cwd inside the work tree. Directory pathspecs pick up
# newly added plugins without a hardcoded per-plugin list.
set --
for group in zsh nvim lua docs; do
  case "$groups" in
    *" $group "*) ;;
    *) continue ;;
  esac
  case "$skips" in
    *" $group "*)
      echo "Skipping $group submodules (excluded)."
      continue
      ;;
  esac
  case "$group" in
    zsh)
      tool=zsh
      path=.local/share/zsh
      ;;
    nvim)
      tool=nvim
      path=.config/nvim/pack/plugins/start
      ;;
    lua)
      tool=lua
      path=.local/share/z.lua
      ;;
    docs)
      tool=zola
      path=.config/dotfiles/docs/themes
      ;;
  esac
  if [ "$group" = lua ]; then
    if ! command -v lua > /dev/null 2>&1 && ! command -v luajit > /dev/null 2>&1; then
      echo "Skipping lua submodule (lua/luajit not found)."
      continue
    fi
  elif ! command -v "$tool" > /dev/null 2>&1; then
    echo "Skipping $group submodules ($tool not found)."
    continue
  fi
  set -- "$@" "$path"
done
if [ "$#" -eq 0 ]; then
  echo "Skipping submodules (none selected with available tools)."
else
  total=$(df ls-files --stage -- "$@" | grep -c '^160000 ' || :)
  echo "Initializing $total submodules (selection: $DOTFILES_SUBMODULES; excluded: ${DOTFILES_SKIP_SUBMODULES:-none})..."
  (cd "$HOME" && df submodule update --init -- "$@")
fi

sh "$BASEDIR/mise-tasks/install-ignore.sh" "$DEST_DIR"

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
