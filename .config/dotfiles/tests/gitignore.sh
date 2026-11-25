#!/bin/sh
# Exercise the installer in disposable normal, linked, and bare repositories.
set -eu

CDPATH=
ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-gitignore-test.XXXXXX")
trap 'rm -rf "$TMP"' EXIT
trap 'exit 1' HUP INT TERM
GIT_CONFIG_GLOBAL=/dev/null
GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

REPO="$TMP/normal clone"
LINKED="$TMP/linked worktree"
BARE="$TMP/bare.git"
mkdir -p "$REPO/.config/dotfiles/mise-tasks/install"
cp "$ROOT/.config/dotfiles/gitignore" "$REPO/.config/dotfiles/gitignore"
cp "$ROOT/.config/dotfiles/mise-tasks/install/gitignore.sh" "$REPO/.config/dotfiles/mise-tasks/install/gitignore.sh"
git init -q "$REPO"
git -C "$REPO" add .
git -C "$REPO" -c user.name=test -c user.email=test@example.invalid \
  commit -q --no-verify -m 'test: exclude fixture'
git -C "$REPO" worktree add -qb linked "$LINKED"
git clone -q --bare "$REPO" "$BARE"

assert_ignored() {
  git -C "$1" check-ignore -q .df-bak/generated || fail "$1: backup is not ignored"
  git -C "$1" check-ignore -q mise.local.toml || fail "$1: development config is not ignored"
}

printf '==> Linked worktree: resolve the common exclude file\n'
sh "$LINKED/.config/dotfiles/mise-tasks/install/gitignore.sh"
COMMON="$REPO/.git/info/exclude"
PRIVATE=$(git -C "$LINKED" rev-parse --absolute-git-dir)
[ -L "$COMMON" ] || fail 'linked installer did not link common info/exclude'
[ ! -e "$PRIVATE/info/exclude" ] && [ ! -L "$PRIVATE/info/exclude" ] || fail 'private exclude was created'
[ "$(readlink "$COMMON")" = "$LINKED/.config/dotfiles/gitignore" ] || fail 'wrong linked ignore target'
[ -f "$COMMON.before-dotfiles" ] || fail 'default common exclude was not backed up'
assert_ignored "$LINKED"
assert_ignored "$REPO"
# Explicit private gitdir must resolve to the same common path, from any cwd.
sh "$LINKED/.config/dotfiles/mise-tasks/install/gitignore.sh" "$PRIVATE"
assert_ignored "$LINKED"

printf '==> Normal clone: link and repeat without replacing the backup\n'
rm "$COMMON"
sh "$REPO/.config/dotfiles/mise-tasks/install/gitignore.sh"
sh "$REPO/.config/dotfiles/mise-tasks/install/gitignore.sh"
[ "$(readlink "$COMMON")" = "$REPO/.config/dotfiles/gitignore" ] || fail 'wrong normal ignore target'
assert_ignored "$REPO"

printf '==> Bare repository: preserve explicit gitdir argument\n'
sh "$REPO/.config/dotfiles/mise-tasks/install/gitignore.sh" "$BARE"
[ -L "$BARE/info/exclude" ] || fail 'bare exclude is not linked'
[ "$(readlink "$BARE/info/exclude")" = "$REPO/.config/dotfiles/gitignore" ] || fail 'wrong bare ignore target'
git --git-dir="$BARE" --work-tree="$REPO" check-ignore -q .df-bak/generated || fail 'bare backup is not ignored'
sh "$REPO/.config/dotfiles/mise-tasks/install/gitignore.sh" "$BARE"
(cd "$TMP" && sh "$REPO/.config/dotfiles/mise-tasks/install/gitignore.sh" bare.git)

printf '==> Linked worktree: preserve custom common rules and foreign symlinks\n'
rm "$COMMON"
printf '/private-local/\n' > "$COMMON"
sh "$LINKED/.config/dotfiles/mise-tasks/install/gitignore.sh" 2> "$TMP/warnings"
[ ! -L "$COMMON" ] || fail 'custom common exclude was replaced'
git -C "$LINKED" check-ignore -q private-local/file || fail 'custom common rule was lost'
grep -q 'contains local rules' "$TMP/warnings" || fail 'missing custom rules warning'
rm "$COMMON"
ln -s "$TMP/missing" "$COMMON"
sh "$LINKED/.config/dotfiles/mise-tasks/install/gitignore.sh" 2> "$TMP/warnings"
[ "$(readlink "$COMMON")" = "$TMP/missing" ] || fail 'foreign common symlink was replaced'
grep -q 'already a symlink' "$TMP/warnings" || fail 'missing symlink warning'

printf 'gitignore tests: ok\n'
