#!/bin/sh
# Deploy dotfiles into $HOME from a bare repo. Requires only git and a POSIX shell;
# mise-managed setup runs afterwards only when mise is available.
# DOTFILES_COMMIT (full commit ID, set by the remote entrypoint) deploys exactly that
# commit and fails if HEAD ends up anywhere else; DOTFILES_BRANCH names the branch a
# pinned fresh install tracks (default: the remote's default branch).

set -eu

REPO_URL="${REPO_URL:-https://github.com/drts01/dotfiles}"
DEST_DIR="${DEST_DIR:-$HOME/.local/share/dotfiles}"
BASEDIR="$HOME/.config/dotfiles"
BACKUP_DIR="$HOME/.df-bak"
DOTFILES_SUBMODULES="${DOTFILES_SUBMODULES-auto}"
DOTFILES_SKIP_SUBMODULES="${DOTFILES_SKIP_SUBMODULES-}"
DOTFILES_COMMIT="${DOTFILES_COMMIT-}"
DOTFILES_BRANCH="${DOTFILES_BRANCH-}"
TAB="$(printf '\t')"

is_commit_id() {
  case "$1" in
    '' | *[!0-9a-f]*) return 1 ;;
  esac
  [ "${#1}" -eq 40 ] || [ "${#1}" -eq 64 ]
}

if [ -n "$DOTFILES_COMMIT" ] && ! is_commit_id "$DOTFILES_COMMIT"; then
  echo "ERROR: DOTFILES_COMMIT must be a full 40- or 64-character lowercase commit ID." >&2
  exit 1
fi

# Plain http, git, and ftp transports carry no server authentication; a network attacker could swap the content.
case "$REPO_URL" in
  http://* | git://* | ftp://*)
    echo "ERROR: REPO_URL $REPO_URL uses an unauthenticated transport; use https://, ssh://, or a local path." >&2
    exit 1
    ;;
esac

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

# `auto` covers runtime plugins only; the docs theme is a build dependency of the
# documentation site, so a deployed $HOME gets it only when explicitly requested.
case "$DOTFILES_SUBMODULES" in
  auto) groups=' zsh nvim lua ' ;;
  all) groups=' zsh nvim lua docs ' ;;
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

if [ ! -d "$DEST_DIR" ] && [ -z "$DOTFILES_COMMIT" ]; then
  echo "Cloning bare repo..."
  git clone --bare --single-branch --depth=1 "$REPO_URL" "$DEST_DIR"
elif [ ! -d "$DEST_DIR" ]; then
  echo "Cloning bare repo at $DOTFILES_COMMIT..."
  branch=$DOTFILES_BRANCH
  if [ -z "$branch" ]; then
    branch=$(git ls-remote --symref "$REPO_URL" HEAD |
      sed -n "s|^ref: refs/heads/\([^$TAB]*\)${TAB}HEAD\$|\1|p")
  fi
  if [ -z "$branch" ]; then
    echo "ERROR: cannot determine the default branch of $REPO_URL; set DOTFILES_BRANCH." >&2
    exit 1
  fi
  object_format=sha1
  if [ "${#DOTFILES_COMMIT}" -eq 64 ]; then object_format=sha256; fi
  # git clone cannot check out a bare commit ID, so assemble the clone in a staging
  # directory; a failed fetch never leaves a half-initialized DEST_DIR behind.
  staging="$DEST_DIR.partial"
  rm -rf "$staging"
  git -c init.defaultObjectFormat="$object_format" init -q --bare "$staging"
  git --git-dir="$staging" config remote.origin.url "$REPO_URL"
  git --git-dir="$staging" fetch -q --depth=1 origin "$DOTFILES_COMMIT"
  git --git-dir="$staging" update-ref "refs/heads/$branch" "$DOTFILES_COMMIT"
  git --git-dir="$staging" symbolic-ref HEAD "refs/heads/$branch"
  mv "$staging" "$DEST_DIR"
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
    # Replaced files may hold credentials (shell history, tokens in rc files).
    (umask 077 && mkdir -p "$BACKUP_DIR")
    chmod 700 "$BACKUP_DIR"
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
elif [ -n "$BRANCH" ] && [ -n "$DOTFILES_COMMIT" ]; then
  echo "Updating to $DOTFILES_COMMIT..."
  # Fetch without --depth so the shallow history connects to HEAD for the fast-forward.
  if ! df cat-file -e "$DOTFILES_COMMIT^{commit}" 2> /dev/null; then
    df fetch -q origin "$DOTFILES_COMMIT"
  fi
  df merge --ff-only "$DOTFILES_COMMIT"
elif [ -n "$BRANCH" ]; then
  echo "Pulling latest changes..."
  df pull --ff-only origin "$BRANCH"
else
  echo "Warning: HEAD is detached; skipping pull." >&2
fi

if [ -n "$DOTFILES_COMMIT" ]; then
  head=$(df rev-parse HEAD)
  if [ "$head" != "$DOTFILES_COMMIT" ]; then
    echo "ERROR: $DEST_DIR is at $head, not DOTFILES_COMMIT $DOTFILES_COMMIT." >&2
    echo "The installed checkout is newer, has diverged, or HEAD is detached." >&2
    exit 1
  fi
  echo "Verified dotfiles commit $DOTFILES_COMMIT."
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
