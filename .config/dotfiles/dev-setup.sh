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

sh "$BASEDIR/mise-tasks/install/gitignore.sh"
for path in .miserc.toml mise.local.toml mise.local.lock; do
  if git -C "$ROOT" ls-files --error-unmatch -- "$path" > /dev/null 2>&1; then
    fail "$path is tracked; refusing to set up development-only configuration"
  fi
  git -C "$ROOT" check-ignore -q "$path" ||
    fail "$path is not ignored; add it to this clone's Git exclude rules first"
done

link_local_config() {
  path=$1
  target=$2
  [ -f "$ROOT/$target" ] || fail "missing development config template: $target"
  if [ -L "$ROOT/$path" ]; then
    [ "$(readlink "$ROOT/$path")" = "$target" ] ||
      fail "$path already links elsewhere; reconcile it manually"
  elif [ -e "$ROOT/$path" ]; then
    if ! cmp -s "$ROOT/$path" "$ROOT/$target"; then
      if [ "$path" != mise.local.toml ] ||
        ! sed '/^locked[[:space:]]*=[[:space:]]*true[[:space:]]*$/d' "$ROOT/$path" | cmp -s "$ROOT/$target" -; then
        fail "$path differs from the development template; merge it manually"
      fi
    fi
    rm "$ROOT/$path"
    ln -s "$target" "$ROOT/$path"
  else
    ln -s "$target" "$ROOT/$path"
  fi
}

link_local_config .miserc.toml .config/dotfiles/dev-miserc.toml
link_local_config mise.local.toml .config/dotfiles/dev-mise-local.toml

LOCK_TARGET=.config/dotfiles/dev-mise.lock
[ -f "$ROOT/$LOCK_TARGET" ] || fail 'missing development mise lockfile'
if [ -L "$ROOT/mise.local.lock" ]; then
  case $(readlink "$ROOT/mise.local.lock") in
    "$LOCK_TARGET") ;;
    .config/dotfiles/mise.lock)
      rm "$ROOT/mise.local.lock"
      ln -s "$LOCK_TARGET" "$ROOT/mise.local.lock"
      ;;
    *) fail 'mise.local.lock already links elsewhere; reconcile it manually' ;;
  esac
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
# Trust the installed maintenance tasks as well as the clone's development tasks.
mise trust "$BASEDIR/mise.toml"
mise --cd "$ROOT" install --locked prek
GIT_DIR=$(git -C "$ROOT" rev-parse --absolute-git-dir)
mise --cd "$ROOT" exec prek -- prek install --config "$BASEDIR/prek.toml" --git-dir "$GIT_DIR"
printf 'Development clone ready. Run mise tasks ls or mise run lint from %s\n' "$ROOT"
