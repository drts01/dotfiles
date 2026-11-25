#!/bin/sh
# Exercise clone setup without installing tools or changing the real home directory.
set -eu

CDPATH=
ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-dev-setup-test.XXXXXX")
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
TOOLS="$REPO/.config/dotfiles"
mkdir -p "$TOOLS/mise-tasks/install" "$TMP/bin" "$TMP/home"
for file in dev-setup.sh gitignore AGENTS.md dev-miserc.toml dev-mise-local.toml dev-mise.lock; do
  cp "$ROOT/.config/dotfiles/$file" "$TOOLS/$file"
done
cp "$ROOT/.config/dotfiles/mise-tasks/install/gitignore.sh" "$TOOLS/mise-tasks/install/gitignore.sh"
# Stub tool installation and hook setup; exercise the real Git and filesystem checks.
printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/mise"
chmod +x "$TMP/bin/mise"
git init -q "$REPO"

setup_clone() {
  env HOME="$TMP/home" PATH="$TMP/bin:$PATH" sh "$TOOLS/dev-setup.sh" > "$TMP/output" 2>&1
}

assert_agent_link() {
  [ -L "$REPO/AGENTS.md" ] || fail 'agent link was not created'
  [ "$(readlink "$REPO/AGENTS.md")" = .config/dotfiles/AGENTS.md ] || fail 'wrong agent link target'
  [ -f "$REPO/AGENTS.md" ] || fail 'agent link does not resolve'
  git -C "$REPO" check-ignore -q AGENTS.md || fail 'agent link is not ignored'
}

printf '==> Fresh clone and repeat setup\n'
setup_clone || {
  cat "$TMP/output"
  fail 'fresh setup failed'
}
assert_agent_link
setup_clone || {
  cat "$TMP/output"
  fail 'repeat setup failed'
}
assert_agent_link
[ ! -e "$TMP/home/AGENTS.md" ] || fail 'setup changed the home directory'

printf '==> Identical file becomes a link\n'
rm "$REPO/AGENTS.md"
cp "$TOOLS/AGENTS.md" "$REPO/AGENTS.md"
setup_clone || {
  cat "$TMP/output"
  fail 'identical file setup failed'
}
assert_agent_link

printf '==> Conflicting file stays unchanged\n'
rm "$REPO/AGENTS.md"
printf 'local instructions\n' > "$REPO/AGENTS.md"
if setup_clone; then fail 'setup accepted conflicting instructions'; fi
grep -q 'AGENTS.md differs' "$TMP/output" || fail 'missing file conflict error'
[ ! -L "$REPO/AGENTS.md" ] || fail 'conflicting file became a link'
[ "$(cat "$REPO/AGENTS.md")" = 'local instructions' ] || fail 'conflicting file changed'

printf '==> Foreign symlink stays unchanged\n'
rm "$REPO/AGENTS.md"
ln -s missing-instructions "$REPO/AGENTS.md"
if setup_clone; then fail 'setup accepted a foreign link'; fi
grep -q 'AGENTS.md already links elsewhere' "$TMP/output" || fail 'missing link conflict error'
[ "$(readlink "$REPO/AGENTS.md")" = missing-instructions ] || fail 'foreign link changed'

printf '==> Tracked root instructions are rejected\n'
rm "$REPO/AGENTS.md"
printf 'tracked instructions\n' > "$REPO/AGENTS.md"
git -C "$REPO" add -f AGENTS.md
if setup_clone; then fail 'setup accepted tracked root instructions'; fi
grep -q 'AGENTS.md is tracked' "$TMP/output" || fail 'missing tracked file error'
git -C "$REPO" rm -q --cached AGENTS.md
rm "$REPO/AGENTS.md"

printf '==> Unignored root instructions are rejected\n'
sed '\|^/AGENTS.md$|d' "$TOOLS/gitignore" > "$TMP/gitignore"
cat "$TMP/gitignore" > "$TOOLS/gitignore"
if setup_clone; then fail 'setup accepted an unignored root path'; fi
grep -q 'AGENTS.md is not ignored' "$TMP/output" || fail 'missing ignore error'
[ ! -e "$REPO/AGENTS.md" ] && [ ! -L "$REPO/AGENTS.md" ] || fail 'unignored link was created'

printf 'dev-setup tests: ok\n'
