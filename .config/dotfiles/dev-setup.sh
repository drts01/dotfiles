#!/bin/sh
# Configure a regular development clone; never run the bare-repo installer here.
set -eu

CDPATH=
BASEDIR=$(cd -- "$(dirname -- "$0")" && pwd -P)
ROOT=$(cd -- "$BASEDIR/../.." && pwd -P)

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

command -v git > /dev/null 2>&1 || fail 'git is required'
command -v mise > /dev/null 2>&1 || fail 'mise is required for development setup'
[ "$(git -C "$ROOT" rev-parse --show-toplevel 2> /dev/null)" = "$ROOT" ] ||
  fail 'run development setup from a regular clone, not the installed dotfiles'

sh "$BASEDIR/mise-tasks/install-ignore.sh"
for path in .miserc.toml mise.local.toml mise.local.lock; do
  if git -C "$ROOT" ls-files --error-unmatch -- "$path" > /dev/null 2>&1; then
    fail "$path is tracked; refusing to set up development-only configuration"
  fi
  git -C "$ROOT" check-ignore -q "$path" ||
    fail "$path is not ignored; add it to this clone's Git exclude rules first"
done

copy_local_config() {
  template=$1
  path=$2
  source=$BASEDIR/$template
  [ -f "$source" ] || fail "missing development config template: $source"
  if [ -e "$ROOT/$path" ] || [ -L "$ROOT/$path" ]; then
    if [ ! -f "$ROOT/$path" ] || ! cmp -s "$source" "$ROOT/$path"; then
      fail "$path already exists with different contents; merge it manually"
    fi
  fi
  cp "$source" "$ROOT/$path"
}

copy_local_config dev-miserc.toml .miserc.toml
copy_local_config dev-mise-local.toml mise.local.toml

LOCK_TARGET=.config/dotfiles/mise.lock
[ -f "$ROOT/$LOCK_TARGET" ] || fail 'missing shared mise lockfile'
if [ -L "$ROOT/mise.local.lock" ]; then
  [ "$(readlink "$ROOT/mise.local.lock")" = "$LOCK_TARGET" ] ||
    fail 'mise.local.lock already links elsewhere; reconcile it manually'
elif [ -e "$ROOT/mise.local.lock" ]; then
  fail 'mise.local.lock already exists; reconcile it manually'
else
  ln -s "$LOCK_TARGET" "$ROOT/mise.local.lock"
fi

loaded_configs=$(mise --cd "$ROOT" config ls --json) || fail 'mise could not read development configuration'
if printf '%s\n' "$loaded_configs" | grep -F "\"path\": \"$ROOT/.config/mise/" > /dev/null; then
  fail 'mise is still loading the clone machine configuration from .config/mise'
fi

mise trust "$ROOT/mise.local.toml"
# The vale hook runs deployment tasks from .config/dotfiles, as in an installed home.
mise trust "$BASEDIR/mise.toml"
mise --cd "$ROOT" install --locked prek
GIT_DIR=$(git -C "$ROOT" rev-parse --absolute-git-dir)
mise --cd "$ROOT" exec prek -- prek install --config "$BASEDIR/prek.toml" --git-dir "$GIT_DIR"
printf 'Development clone ready. Run mise tasks ls or mise run lint from %s\n' "$ROOT"
