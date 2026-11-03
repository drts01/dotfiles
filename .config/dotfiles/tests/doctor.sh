#!/bin/sh
# Exercise doctor against a throwaway bare repository, without inspecting $HOME.
set -eu

CDPATH=
BASEDIR=$(cd -- "$(dirname -- "$0")/.." && pwd -P)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-doctor-test.XXXXXX")
trap 'rm -rf "$TMP"' EXIT
trap 'exit 1' HUP INT TERM

GIT_CONFIG_GLOBAL=/dev/null
GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  cat "$TMP/output" >&2
  exit 1
}

assert_contains() {
  grep -F "$1" "$TMP/output" > /dev/null || fail "expected: $1"
}

HOME_DIR="$TMP/home"
REPO="$HOME_DIR/.local/share/dotfiles"
mkdir -p "$TMP/bin" "$HOME_DIR/.local/share" "$TMP/source"
ln -s "$(command -v git)" "$TMP/bin/git"
ln -s "$(command -v grep)" "$TMP/bin/grep"
printf 'original\n' > "$TMP/source/.profile"
git -C "$TMP/source" init -q
git -C "$TMP/source" add .profile
git -C "$TMP/source" -c user.name=test -c user.email=test@example.invalid commit -q -m fixture
git clone --bare -q "$TMP/source" "$REPO"
git --git-dir="$REPO" --work-tree="$HOME_DIR" checkout -q -f
git --git-dir="$REPO" config status.showUntrackedFiles no

run_doctor() {
  env -i HOME="$HOME_DIR" DEST_DIR="${1:-$REPO}" PATH="$TMP/bin" \
    /bin/sh "$BASEDIR/mise-tasks/doctor.sh" > "$TMP/output" 2>&1
}

run_doctor || fail 'git-only install should pass'
assert_contains 'Tracked files                  ... OK (clean)'
assert_contains 'Binary: mise                   ... WARN'
assert_contains 'Binary: prek                   ... WARN'
assert_contains 'Pre-commit hook                ... WARN'

printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/mise"
printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/prek"
chmod +x "$TMP/bin/mise" "$TMP/bin/prek"
mkdir -p "$REPO/hooks"
printf '#!/bin/sh\n' > "$REPO/hooks/pre-commit"
chmod +x "$REPO/hooks/pre-commit"
if run_doctor; then fail 'an installed hook without bare-repo configuration should fail'; fi
assert_contains 'Bare-repo hook configuration   ... FAIL'

printf '#!/bin/sh\nexport GIT_DIR="%s" GIT_WORK_TREE="%s"\n' "$REPO" "$HOME_DIR" > "$REPO/hooks/pre-commit"
run_doctor || fail 'clean install with a configured hook should pass'
assert_contains 'All installation checks passed.'

printf 'modified\n' >> "$HOME_DIR/.profile"
run_doctor || fail 'modified tracked files should not fail the install check'
assert_contains 'Tracked files                  ... WARN (changes present'

mkdir "$TMP/not-a-repo"
if run_doctor "$TMP/not-a-repo"; then fail 'a non-repository directory should fail'; fi
assert_contains 'Bare repository integrity      ... FAIL'

printf 'doctor checks passed\n'
