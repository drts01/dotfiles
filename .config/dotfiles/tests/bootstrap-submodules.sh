#!/bin/sh
# Exercise partial installs with local git submodules; no network or mise required.
set -eu

CDPATH=
ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-submodules-test.XXXXXX")
trap 'rm -rf "$TMP"' EXIT
trap 'exit 1' HUP INT TERM
GIT_CONFIG_GLOBAL=/dev/null
GIT_CONFIG_NOSYSTEM=1
GIT_ALLOW_PROTOCOL='file'
export GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_ALLOW_PROTOCOL

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

mkdir -p "$TMP/plugin" "$TMP/fixture/.config/dotfiles/mise-tasks" "$TMP/home"
printf 'plugin\n' > "$TMP/plugin/marker"
git -C "$TMP/plugin" init -q
git -C "$TMP/plugin" add marker
git -C "$TMP/plugin" -c user.name=test -c user.email=test@example.invalid commit -qm plugin

git -C "$TMP/fixture" init -q
for path in \
  .local/share/zsh/plugins/fast-syntax-highlighting \
  .local/share/z.lua \
  .config/nvim/pack/plugins/start/LuaSnip \
  .config/dotfiles/docs/themes/devlab-theme; do
  git -C "$TMP/fixture" submodule add -q "$TMP/plugin" "$path"
done
cp "$ROOT/.config/nvim/init.lua" "$TMP/fixture/.config/nvim/init.lua"
cp "$ROOT/.config/dotfiles/gitignore" "$TMP/fixture/.config/dotfiles/gitignore"
cp "$ROOT/.config/dotfiles/mise-tasks/bootstrap.sh" "$TMP/fixture/.config/dotfiles/mise-tasks/bootstrap.sh"
cp "$ROOT/.config/dotfiles/mise-tasks/install-ignore.sh" "$TMP/fixture/.config/dotfiles/mise-tasks/install-ignore.sh"
cp "$ROOT/.config/dotfiles/mise-tasks/install-hooks.sh" "$TMP/fixture/.config/dotfiles/mise-tasks/install-hooks.sh"
git -C "$TMP/fixture" add .
git -C "$TMP/fixture" -c user.name=test -c user.email=test@example.invalid commit -qm fixture
git clone -q --bare "$TMP/fixture" "$TMP/origin.git"

HOME_DIR="$TMP/home"
run_auto() {
  env -i HOME="$HOME_DIR" PATH="$1" GIT_CONFIG_GLOBAL=/dev/null \
    GIT_CONFIG_NOSYSTEM=1 GIT_ALLOW_PROTOCOL=file REPO_URL="file://$TMP/origin.git" \
    DOTFILES_SKIP_SUBMODULES="${2-}" sh "$ROOT/.config/dotfiles/mise-tasks/bootstrap.sh"
}
run() {
  env -i HOME="$HOME_DIR" PATH="$2" GIT_CONFIG_GLOBAL=/dev/null \
    GIT_CONFIG_NOSYSTEM=1 GIT_ALLOW_PROTOCOL=file REPO_URL="file://$TMP/origin.git" \
    DOTFILES_SUBMODULES="$1" DOTFILES_SKIP_SUBMODULES="${3-}" \
    sh "$ROOT/.config/dotfiles/mise-tasks/bootstrap.sh"
}
check() {
  path=$1
  expected=$2
  if [ -f "$HOME_DIR/$path/marker" ]; then actual=installed; else actual=absent; fi
  [ "$actual" = "$expected" ] || fail "$path: expected $expected, got $actual"
}
check_groups() {
  check .local/share/zsh/plugins/fast-syntax-highlighting "$1"
  check .local/share/z.lua "$2"
  check .config/nvim/pack/plugins/start/LuaSnip "$3"
  check .config/dotfiles/docs/themes/devlab-theme "$4"
}

# Control PATH independently of the host's installed editor, shells and build tools.
mkdir -p "$TMP/core-bin" "$TMP/tools-bin" "$TMP/luajit-bin"
for tool in git sh dirname mkdir mv grep ln readlink sed basename cat tr uname sort cut rm touch expr date head; do
  ln -s "$(command -v "$tool")" "$TMP/core-bin/$tool"
done
cp -R "$TMP/core-bin/." "$TMP/tools-bin/"
cp -R "$TMP/core-bin/." "$TMP/luajit-bin/"
for tool in zsh nvim lua zola; do
  printf '#!/bin/sh\nexit 0\n' > "$TMP/tools-bin/$tool"
  chmod +x "$TMP/tools-bin/$tool"
done
printf '#!/bin/sh\nexit 0\n' > "$TMP/luajit-bin/luajit"
chmod +x "$TMP/luajit-bin/luajit"

if run 'zsh,invalid' "$TMP/core-bin" > "$TMP/invalid-out" 2>&1; then fail 'invalid group accepted'; fi
[ ! -e "$HOME_DIR/.local/share/dotfiles" ] || fail 'invalid group modified the home'
grep -q 'DOTFILES_SUBMODULES must be' "$TMP/invalid-out" || fail 'missing selection validation error'
if run auto "$TMP/core-bin" 'nvim,invalid' > "$TMP/invalid-out" 2>&1; then fail 'invalid exclusion accepted'; fi
[ ! -e "$HOME_DIR/.local/share/dotfiles" ] || fail 'invalid exclusion modified the home'
grep -q 'DOTFILES_SKIP_SUBMODULES must be' "$TMP/invalid-out" || fail 'missing exclusion validation error'

# With no related tools, neither auto nor all should fetch a submodule.
run_auto "$TMP/core-bin" > "$TMP/no-tools-out"
grep -q 'Skipping submodules' "$TMP/no-tools-out" || fail 'missing no-tools stage'
check_groups absent absent absent absent
run all "$TMP/core-bin" > "$TMP/no-tools-out"
check_groups absent absent absent absent
if command -v nvim > /dev/null 2>&1; then
  # An uninitialized gitlink has a directory, but no plugin entrypoints.
  env -i HOME="$HOME_DIR" XDG_CONFIG_HOME="$HOME_DIR/.config" \
    XDG_DATA_HOME="$HOME_DIR/.local/share" PATH="$PATH" \
    nvim --headless -u "$HOME_DIR/.config/nvim/init.lua" -c 'qa!' > "$TMP/nvim-out" 2>&1 || {
    cat "$TMP/nvim-out" >&2
    fail 'Neovim failed without submodules'
  }
fi

HOME_DIR="$TMP/home-auto"
mkdir -p "$HOME_DIR"
run_auto "$TMP/tools-bin" > "$TMP/auto-out"
grep -q 'Initializing 4 submodules' "$TMP/auto-out" || fail 'auto stage count incorrect'
check_groups installed installed installed installed
run_auto "$TMP/core-bin" all > "$TMP/skip-all-out"
check_groups installed installed installed installed

HOME_DIR="$TMP/home-skip"
mkdir -p "$HOME_DIR"
run_auto "$TMP/tools-bin" nvim > "$TMP/skip-out"
check_groups installed installed absent installed
run all "$TMP/tools-bin" nvim > "$TMP/skip-out"
check_groups installed installed absent installed
run auto "$TMP/tools-bin" all > "$TMP/skip-out"
check_groups installed installed absent installed

HOME_DIR="$TMP/home-luajit"
mkdir -p "$HOME_DIR"
run_auto "$TMP/luajit-bin" > "$TMP/luajit-out"
check_groups absent installed absent absent

HOME_DIR="$TMP/home"
run nvim "$TMP/core-bin" > "$TMP/nvim-out"
check_groups absent absent absent absent
run nvim "$TMP/tools-bin" > "$TMP/nvim-out"
check_groups absent absent installed absent
run 'zsh,docs' "$TMP/tools-bin" > "$TMP/combined-out"
check_groups installed absent installed installed
run lua "$TMP/tools-bin" > "$TMP/lua-out"
check_groups installed installed installed installed
run none "$TMP/tools-bin" > "$TMP/none-out"
check_groups installed installed installed installed

printf 'bootstrap submodule tests: ok\n'
