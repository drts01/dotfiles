#!/bin/sh
# Integration test: deploy the dotfiles into throwaway home directories without mise.
# Covers the remote entrypoint, backups, a repeat run (idempotency), a
# fast-forward pull, commit pinning, and the git-only install path. The scripts under
# test are the working-tree copies; the deployed content is the committed HEAD.
# Requires git and network access for submodules. With mise skipped, the entrypoint
# fetches only through git, so neither curl nor wget is exercised.
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
  [ "$(git config --file "$_home/.local/share/dotfiles/config" --get core.bare)" = true ] ||
    fail "$_home: repo is not bare"
  if git config --file "$_home/.local/share/dotfiles/config" --get core.worktree > /dev/null; then
    fail "$_home: legacy core.worktree was not removed"
  fi
  [ "$(dfg "$_home" config status.showUntrackedFiles)" = no ] ||
    fail "$_home: status.showUntrackedFiles is not 'no'"
  [ -L "$_home/.local/share/dotfiles/info/exclude" ] || fail "$_home: Git exclude is not linked"
  [ "$(readlink "$_home/.local/share/dotfiles/info/exclude")" = "$(cd "$_home/.config/dotfiles" && pwd)/gitignore" ] ||
    fail "$_home: Git exclude points to the wrong file"
  dfg "$_home" check-ignore -q "$_home/.df-bak/generated" || fail "$_home: backup directory is not ignored"
  [ "$(dfg "$_home" config remote.origin.fetch)" = "+refs/heads/trunk:refs/remotes/origin/trunk" ] ||
    fail "$_home: remote.origin.fetch refspec not set"
  [ -z "$(dfg "$_home" status --porcelain)" ] || fail "$_home: work tree is not clean"
  for pair in 'zsh .local/share/zsh' 'nvim .config/nvim/pack/plugins/start' \
    'lua .local/share/z.lua'; do
    tool=${pair%% *}
    path=${pair#* }
    available=false
    # The tool name is expanded by the isolated child shell, not this test shell.
    # shellcheck disable=SC2016
    if env -i PATH="$TEST_PATH" sh -c 'command -v "$1"' sh "$tool" > /dev/null; then
      available=true
    elif [ "$tool" = lua ] && env -i PATH="$TEST_PATH" sh -c 'command -v luajit' > /dev/null; then
      available=true
    fi
    if [ "$available" = true ]; then
      if (cd "$_home" && dfg "$_home" submodule status -- "$path") | grep -q '^-'; then
        fail "$_home: $tool submodules not initialized with tool on PATH"
      fi
    elif (cd "$_home" && dfg "$_home" submodule status -- "$path") | grep -qv '^-'; then
      fail "$_home: $tool submodules initialized without tool on PATH"
    fi
  done
  # The docs theme is opt-in: the default selection never installs it, even with zola present.
  if (cd "$_home" && dfg "$_home" submodule status -- .config/dotfiles/docs/themes) | grep -qv '^-'; then
    fail "$_home: docs theme initialized by the default selection"
  fi
}

assert_head() {
  [ "$(dfg "$1" rev-parse HEAD)" = "$2" ] || fail "$1: HEAD is not $2"
}

env -i PATH="$TEST_PATH" sh -c 'command -v git' > /dev/null || fail "git not found in $TEST_PATH"
if env -i PATH="$TEST_PATH" sh -c 'command -v mise' > /dev/null; then
  fail "mise found in $TEST_PATH; the test requires a mise-free PATH"
fi

step "Creating fixture origin"
git init -q --bare "$ORIGIN"
# CI checkouts are shallow; accept their truncated history.
git --git-dir="$ORIGIN" config receive.shallowUpdate true
src_git push -q --no-verify "$ORIGIN" HEAD:refs/heads/trunk
git --git-dir="$ORIGIN" symbolic-ref HEAD refs/heads/trunk
# Tests run before changes are committed; publish the files under test to the fixture.
git clone -q "file://$ORIGIN" "$TMP/fixture"
cp "$ROOT/.config/dotfiles/gitignore" "$TMP/fixture/.config/dotfiles/gitignore"
cp "$ROOT/.config/dotfiles/mise-tasks/install/gitignore.sh" "$TMP/fixture/.config/dotfiles/mise-tasks/install/gitignore.sh"
cp "$DEPLOY" "$TMP/fixture/.config/dotfiles/mise-tasks/bootstrap.sh"
git -C "$TMP/fixture" add .config/dotfiles/gitignore .config/dotfiles/mise-tasks/install/gitignore.sh .config/dotfiles/mise-tasks/bootstrap.sh
git -C "$TMP/fixture" -c user.name=test -c user.email=test@example.invalid \
  commit -q --allow-empty --no-verify -m "test: publish ignore installer"
git -C "$TMP/fixture" push -q --no-verify origin HEAD:trunk
# The first commit whose deploy script supports DOTFILES_COMMIT; later steps pin to it.
PINNED=$(git -C "$TMP/fixture" rev-parse HEAD)

HOME_A="$TMP/home-a"
mkdir -p "$HOME_A"
printf 'pre-existing\n' > "$HOME_A/.bashrc"

step "Entrypoint: fresh install with a conflicting file"
mkdir -p "$TMP/bin"
# Expand the marker in the downloader stub, not while writing it.
# shellcheck disable=SC2016
printf '%s\n' '#!/bin/sh' ': > "$TEST_FETCH_MARKER"' 'exit 1' > "$TMP/bin/curl"
chmod +x "$TMP/bin/curl"
run "$HOME_A" PATH="$TMP/bin:$TEST_PATH" TEST_FETCH_MARKER="$TMP/mise-fetch-called" \
  DOTFILES_SKIP_MISE_INSTALL=1 sh "$ENTRYPOINT"
[ ! -e "$TMP/mise-fetch-called" ] || fail "mise download attempted despite DOTFILES_SKIP_MISE_INSTALL"
assert_deployed "$HOME_A"
assert_head "$HOME_A" "$PINNED"
[ "$(cat "$HOME_A/.df-bak/.bashrc")" = pre-existing ] || fail "conflicting .bashrc not backed up"
[ -n "$(find "$HOME_A/.df-bak" -prune -perm 700)" ] || fail "backup directory is not private"

step "Entrypoint: repeat run removes legacy core.worktree and is idempotent"
BEFORE=$(snapshot "$HOME_A")
git config --file "$HOME_A/.local/share/dotfiles/config" core.worktree "$HOME_A"
run "$HOME_A" DOTFILES_SKIP_MISE_INSTALL=1 sh "$ENTRYPOINT" 2> "$TMP/repeat-stderr"
if grep -q 'core.bare and core.worktree' "$TMP/repeat-stderr"; then
  fail "repeat run emitted the bare repo worktree warning"
fi
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

step "Upgrade: fetch current deploy script before running the installed copy"
cp "$DEPLOY" "$TMP/upstream/.config/dotfiles/mise-tasks/bootstrap.sh"
git -C "$TMP/upstream" add .config/dotfiles/mise-tasks/bootstrap.sh
# A future checkout may already contain this version; still exercise the upgrade path.
git -C "$TMP/upstream" -c user.name=test -c user.email=test@example.invalid \
  commit -q --allow-empty --no-verify -m "test: publish current deploy script"
git -C "$TMP/upstream" push -q --no-verify origin HEAD:trunk
git config --file "$HOME_A/.local/share/dotfiles/config" core.worktree "$HOME_A"
run "$HOME_A" DOTFILES_SKIP_MISE_INSTALL=1 sh "$ENTRYPOINT" 2> "$TMP/upgrade-stderr"
if grep -q 'core.bare and core.worktree' "$TMP/upgrade-stderr"; then
  fail "upgrade emitted the bare repo worktree warning"
fi
assert_deployed "$HOME_A"
# git instead of cmp: minimal images (Fedora) ship without diffutils.
git diff --no-index --quiet "$DEPLOY" "$HOME_A/.config/dotfiles/mise-tasks/bootstrap.sh" ||
  fail "upgrade did not replace the installed deploy script"
run "$HOME_A" sh "$HOME_A/.config/dotfiles/mise-tasks/bootstrap.sh"
assert_deployed "$HOME_A"
TIP=$(git --git-dir="$ORIGIN" rev-parse trunk)
assert_head "$HOME_A" "$TIP"

step "Entrypoint: refuse a pin older than the installed commit"
if run "$HOME_A" DOTFILES_SKIP_MISE_INSTALL=1 DOTFILES_REF="$PINNED" sh "$ENTRYPOINT" > "$TMP/older-out" 2>&1; then
  fail "pin older than the installed commit was accepted"
fi
grep -q 'not DOTFILES_COMMIT' "$TMP/older-out" || fail "missing pin mismatch error"
assert_head "$HOME_A" "$TIP"

step "Entrypoint: reject an unknown commit before touching \$HOME"
HOME_C="$TMP/home-c"
mkdir -p "$HOME_C"
if run "$HOME_C" DOTFILES_SKIP_MISE_INSTALL=1 DOTFILES_REF=0000000000000000000000000000000000000000 \
  sh "$ENTRYPOINT" > "$TMP/unknown-out" 2>&1; then
  fail "unknown commit was accepted"
fi
if [ -e "$HOME_C/.local" ] || [ -e "$HOME_C/.config" ]; then fail "unknown commit modified $HOME_C"; fi

step "Installer: reject unauthenticated transports before touching \$HOME"
for script in "$ENTRYPOINT" "$DEPLOY"; do
  if run "$HOME_C" REPO_URL=http://example.invalid/dotfiles DOTFILES_SKIP_MISE_INSTALL=1 sh "$script" \
    > "$TMP/transport-out" 2>&1; then
    fail "$script accepted an http:// REPO_URL"
  fi
  grep -q 'unauthenticated transport' "$TMP/transport-out" || fail "$script: missing transport error"
done
if [ -e "$HOME_C/.local" ] || [ -e "$HOME_C/.config" ]; then fail "http:// REPO_URL modified $HOME_C"; fi

step "Entrypoint: pinned fresh install, then follow the default branch"
run "$HOME_C" DOTFILES_SKIP_MISE_INSTALL=1 DOTFILES_REF="$PINNED" sh "$ENTRYPOINT"
assert_deployed "$HOME_C"
assert_head "$HOME_C" "$PINNED"
[ ! -e "$HOME_C/.bootstrap-test" ] || fail "pinned install deployed a later commit"
run "$HOME_C" DOTFILES_SKIP_MISE_INSTALL=1 sh "$ENTRYPOINT"
assert_deployed "$HOME_C"
assert_head "$HOME_C" "$TIP"

step "Entrypoint: a commit pin tracks the caller's DOTFILES_BRANCH"
HOME_D="$TMP/home-d"
mkdir -p "$HOME_D"
run "$HOME_D" DOTFILES_SKIP_MISE_INSTALL=1 DOTFILES_SUBMODULES=none DOTFILES_REF="$PINNED" DOTFILES_BRANCH=pinned \
  sh "$ENTRYPOINT"
assert_head "$HOME_D" "$PINNED"
[ "$(dfg "$HOME_D" symbolic-ref --short HEAD)" = pinned ] || fail "commit pin ignored DOTFILES_BRANCH"

step "Deploy: git-only install into a pre-cloned bare repo"
HOME_B="$TMP/home-b"
mkdir -p "$HOME_B/.local/share"
git clone -q --bare --single-branch --depth=1 "file://$ORIGIN" "$HOME_B/.local/share/dotfiles"
run "$HOME_B" sh "$DEPLOY"
assert_deployed "$HOME_B"

step "Installer: preserve existing local exclude rules"
INFO_B="$HOME_B/.local/share/dotfiles/info"
[ -f "$INFO_B/exclude.before-dotfiles" ] || fail "original exclude was not backed up"
rm "$INFO_B/exclude"
mv "$INFO_B/exclude.before-dotfiles" "$INFO_B/exclude"
printf '/.private/\n' >> "$INFO_B/exclude"
run "$HOME_B" sh "$HOME_B/.config/dotfiles/mise-tasks/install/gitignore.sh" "$HOME_B/.local/share/dotfiles" \
  2> "$TMP/custom-exclude-stderr"
[ ! -L "$INFO_B/exclude" ] || fail "custom exclude was replaced"
grep -qF '/.private/' "$INFO_B/exclude" || fail "custom exclude rule was lost"
grep -qF 'contains local rules' "$TMP/custom-exclude-stderr" || fail "missing custom exclude warning"

printf 'bootstrap tests: ok\n'
