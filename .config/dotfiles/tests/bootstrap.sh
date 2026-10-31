#!/bin/sh
# Integration test: deploy the dotfiles into throwaway home directories without mise.
# Covers the curl entrypoint, backups, a repeat run (idempotency), a
# fast-forward pull, and the git-only install path. The scripts under test are
# the working-tree copies; the deployed content is the committed HEAD.
# Requires git, curl, and network access for submodules.
set -eu

CDPATH=
ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-bootstrap-test.XXXXXX")
trap 'rm -rf "$TMP"' EXIT
trap 'exit 1' HUP INT TERM

ENTRYPOINT="$ROOT/.config/dotfiles/bootstrap.sh"
DEPLOY="$ROOT/.config/dotfiles/mise-tasks/bootstrap.sh"
ORIGIN="$TMP/origin.git"
# Keeps mise out of the deploy runs so the git-only path is exercised.
TEST_PATH=/usr/bin:/bin

# The developer's global git config (e.g. sha256 object format, signing) must not
# leak into fixture repos.
GIT_CONFIG_GLOBAL=/dev/null
GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

step() { printf '==> %s\n' "$*"; }

# Runs a command against a clean environment rooted at the given $HOME.
run() {
  _home=$1
  shift
  env -i HOME="$_home" PATH="$TEST_PATH" REPO_URL="file://$ORIGIN" "$@"
}

dfg() {
  _home=$1
  shift
  git --git-dir="$_home/.local/share/dotfiles" --work-tree="$_home" "$@"
}

# Source repo: a normal clone, or the bare repo when run from an installed $HOME.
# safe.directory: CI mounts the checkout into a container under another uid.
src_git() {
  if [ -e "$ROOT/.git" ]; then
    git -c safe.directory='*' -C "$ROOT" "$@"
  else
    git -c safe.directory='*' --git-dir="${DEST_DIR:-$HOME/.local/share/dotfiles}" "$@"
  fi
}

snapshot() {
  (cd "$1" && find . -path ./.local/share/dotfiles -prune -o -print | LC_ALL=C sort)
  dfg "$1" rev-parse HEAD
}

assert_deployed() {
  _home=$1
  [ -f "$_home/.config/dotfiles/mise-tasks/bootstrap.sh" ] || fail "$_home: dotfiles not checked out"
  [ "$(dfg "$_home" config status.showUntrackedFiles)" = no ] ||
    fail "$_home: status.showUntrackedFiles is not 'no'"
  [ "$(dfg "$_home" config remote.origin.fetch)" = "+refs/heads/trunk:refs/remotes/origin/trunk" ] ||
    fail "$_home: remote.origin.fetch refspec not set"
  [ -z "$(dfg "$_home" status --porcelain)" ] || fail "$_home: work tree is not clean"
  if (cd "$_home" && dfg "$_home" submodule status) | grep -q '^-'; then
    fail "$_home: uninitialized submodules"
  fi
}

env -i PATH="$TEST_PATH" sh -c 'command -v git' > /dev/null || fail "git not found in $TEST_PATH"
env -i PATH="$TEST_PATH" sh -c 'command -v curl' > /dev/null || fail "curl not found in $TEST_PATH"
if env -i PATH="$TEST_PATH" sh -c 'command -v mise' > /dev/null; then
  fail "mise found in $TEST_PATH; the test requires a mise-free PATH"
fi

step "Creating fixture origin"
git init -q --bare "$ORIGIN"
# CI checkouts are shallow; accept their truncated history.
git --git-dir="$ORIGIN" config receive.shallowUpdate true
src_git push -q --no-verify "$ORIGIN" HEAD:refs/heads/trunk
git --git-dir="$ORIGIN" symbolic-ref HEAD refs/heads/trunk

HOME_A="$TMP/home-a"
mkdir -p "$HOME_A"
printf 'pre-existing\n' > "$HOME_A/.bashrc"

step "Entrypoint: fresh install with a conflicting file"
run "$HOME_A" SKIP_MISE_INSTALL=1 RAW_URL="file://$ROOT" sh "$ENTRYPOINT"
assert_deployed "$HOME_A"
[ "$(cat "$HOME_A/.df-bak/.bashrc")" = pre-existing ] || fail "conflicting .bashrc not backed up"

step "Entrypoint: repeat run is idempotent"
BEFORE=$(snapshot "$HOME_A")
run "$HOME_A" SKIP_MISE_INSTALL=1 RAW_URL="file://$ROOT" sh "$ENTRYPOINT"
assert_deployed "$HOME_A"
[ "$(snapshot "$HOME_A")" = "$BEFORE" ] || fail "repeat run changed $HOME_A"

step "Deploy: fast-forwards upstream changes"
git clone -q "file://$ORIGIN" "$TMP/upstream"
printf 'upstream\n' > "$TMP/upstream/.bootstrap-test"
git -C "$TMP/upstream" add .bootstrap-test
git -C "$TMP/upstream" -c user.name=test -c user.email=test@example.invalid \
  commit -q --no-verify -m "test: upstream change"
git -C "$TMP/upstream" push -q --no-verify origin HEAD:trunk
run "$HOME_A" sh "$DEPLOY"
assert_deployed "$HOME_A"
[ "$(cat "$HOME_A/.bootstrap-test")" = upstream ] || fail "upstream change not pulled"

step "Deploy: git-only install into a pre-cloned bare repo"
HOME_B="$TMP/home-b"
mkdir -p "$HOME_B/.local/share"
git clone -q --bare --single-branch --depth=1 "file://$ORIGIN" "$HOME_B/.local/share/dotfiles"
run "$HOME_B" sh "$DEPLOY"
assert_deployed "$HOME_B"

printf 'bootstrap tests: ok\n'
