#!/bin/sh
# shellcheck shell=sh
set -eu

CDPATH=
ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
FIXTURE=$ROOT/.config/dotfiles/tests/mise
TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-mise-smoke.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

for shell in /bin/sh bash zsh script; do
  command -v "$shell" > /dev/null 2>&1 || fail "required executable unavailable: $shell"
done
case $(uname -s) in
  Darwin | Linux) : ;;
  *) fail 'only macOS and Linux are supported by this smoke test' ;;
esac
command -v mise > /dev/null 2>&1 || fail 'mise is required; install mise and run mise --cd .config/dotfiles/tests/mise install --locked'
MISE=$(command -v mise)

# Resolve only the fixture; never pick up personal tools or runner-wide configuration.
export MISE_GLOBAL_CONFIG_FILE="$FIXTURE/mise.toml"
export MISE_TRUSTED_CONFIG_PATHS="$FIXTURE"
export MISE_IGNORED_CONFIG_PATHS="$ROOT/.config/mise:$ROOT/.config/dotfiles/mise.toml"
export MISE_CEILING_PATHS="$ROOT"
export MISE_CONFIG_DIR="${MISE_CONFIG_DIR:-$TMP/mise-config}"
export MISE_DATA_DIR="${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}"
export MISE_CACHE_DIR="${MISE_CACHE_DIR:-$TMP/mise-cache}"
export MISE_STATE_DIR="${MISE_STATE_DIR:-$TMP/mise-state}"
export MISE_ENABLE_TOOLS=zoxide,atuin

ZOXIDE=$("$MISE" --cd "$FIXTURE" which --locked zoxide) || fail 'zoxide is not installed from the locked fixture'
ATUIN=$("$MISE" --cd "$FIXTURE" which --locked atuin) || fail 'atuin is not installed from the locked fixture'
[ -x "$ZOXIDE" ] || fail "zoxide executable missing: $ZOXIDE"
[ -x "$ATUIN" ] || fail "atuin executable missing: $ATUIN"
"$MISE" --cd "$FIXTURE" reshim || fail 'mise could not generate tool shims'
for tool in zoxide atuin; do
  [ -x "$MISE_DATA_DIR/shims/$tool" ] || fail "mise shim missing: $tool"
done
for plugin in \
  plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  themes/spaceship-prompt/spaceship.zsh; do
  [ -r "$ROOT/.local/share/zsh/$plugin" ] || fail "initialize submodule: $plugin"
done

HOME_DIR=$TMP/home
mkdir -p "$HOME_DIR/.config" "$HOME_DIR/.local/share" "$HOME_DIR/.local/state" "$HOME_DIR/.cache" "$TMP/bin"
for file in .profile .bash_profile .bashrc .zshenv; do
  ln -s "$ROOT/$file" "$HOME_DIR/$file"
done
ln -s "$ROOT/.config/sh" "$HOME_DIR/.config/sh"
ln -s "$ROOT/.config/zsh" "$HOME_DIR/.config/zsh"
ln -s "$ROOT/.config/spaceship.zsh" "$HOME_DIR/.config/spaceship.zsh"
ln -s "$ROOT/.local/share/zsh" "$HOME_DIR/.local/share/zsh"
ln -s "$MISE" "$TMP/bin/mise"
PATH_TEST="$TMP/bin:$MISE_DATA_DIR/shims:${ZOXIDE%/*}:${ATUIN%/*}:/usr/bin:/bin"
BASH=$(command -v bash)
ZSH=$(command -v zsh)
ZOXIDE_VERSION=$("$ZOXIDE" --version)
ATUIN_VERSION=$("$ATUIN" --version)

# Atuin's Bash initialization reads terminal settings, so give every interactive
# shell a real pty rather than filtering away job-control or stty errors.
cat > "$TMP/runner" << 'EOF'
#!/bin/sh
cd "$SMOKE_WORK_DIR" || exit 1
if [ "$SMOKE_ZSH" = 1 ]; then
  "$SMOKE_SHELL" -d -li -c "$SMOKE_CHECK" 2> "$SMOKE_STDERR"
else
  "$SMOKE_SHELL" -li -c "$SMOKE_CHECK" 2> "$SMOKE_STDERR"
fi
result=$?
printf '%s\n' "$result" > "$SMOKE_STATUS"
exit "$result"
EOF
chmod +x "$TMP/runner"

run_startup() {
  label=$1
  check=$2
  shell=$3
  zsh_mode=0
  [ "$shell" = "$ZSH" ] && zsh_mode=1
  rm -f "$TMP/status" "$TMP/stderr"
  case $(uname -s) in
    Darwin) set -- -q /dev/null "$TMP/runner" ;;
    Linux) set -- -q -e -c "$TMP/runner" /dev/null ;;
  esac
  if env -i HOME="$HOME_DIR" PATH="$PATH_TEST" TERM=dumb HOMEBREW_PREFIX=/nonexistent \
    XDG_CONFIG_HOME="$HOME_DIR/.config" XDG_DATA_HOME="$HOME_DIR/.local/share" \
    XDG_STATE_HOME="$HOME_DIR/.local/state" XDG_CACHE_HOME="$HOME_DIR/.cache" \
    ENV="$HOME_DIR/.config/sh/.shrc" MISE_GLOBAL_CONFIG_FILE="$MISE_GLOBAL_CONFIG_FILE" \
    MISE_TRUSTED_CONFIG_PATHS="$MISE_TRUSTED_CONFIG_PATHS" \
    MISE_IGNORED_CONFIG_PATHS="$MISE_IGNORED_CONFIG_PATHS" \
    MISE_CEILING_PATHS="$MISE_CEILING_PATHS" MISE_CONFIG_DIR="$MISE_CONFIG_DIR" \
    MISE_DATA_DIR="$MISE_DATA_DIR" MISE_CACHE_DIR="$MISE_CACHE_DIR" \
    MISE_STATE_DIR="$MISE_STATE_DIR" MISE_ENABLE_TOOLS="$MISE_ENABLE_TOOLS" \
    SMOKE_SHELL="$shell" SMOKE_ZSH="$zsh_mode" SMOKE_CHECK="$check" \
    SMOKE_STATUS="$TMP/status" SMOKE_STDERR="$TMP/stderr" SMOKE_WORK_DIR="$TMP" \
    SMOKE_ZOXIDE_VERSION="$ZOXIDE_VERSION" SMOKE_ATUIN_VERSION="$ATUIN_VERSION" \
    script "$@" > "$TMP/stdout" 2> "$TMP/script-stderr"; then
    :
  else
    cat "$TMP/script-stderr" >&2
    cat "$TMP/stdout" >&2
    fail "$label: could not start a pseudo-terminal"
  fi
  if [ ! -f "$TMP/status" ] || [ "$(cat "$TMP/status")" != 0 ]; then
    cat "$TMP/stderr" "$TMP/script-stderr" "$TMP/stdout" >&2
    fail "$label: startup or tool hook failed"
  fi
  # Capturing stderr can provoke shell-specific job-control warnings even with
  # a pty. Remove only these known, anchored messages, never tool diagnostics.
  case $(uname -s) in
    Darwin)
      sed -e '/^sh: no job control in this shell$/d' \
        -e '/^bash: no job control in this shell$/d' "$TMP/stderr" > "$TMP/checked-stderr"
      ;;
    Linux)
      sed -e "/^sh: 0: can't access tty; job control turned off$/d" \
        -e '/^bash: no job control in this shell$/d' \
        -E -e '/^bash: cannot set terminal process group \([0-9]+\): Inappropriate ioctl for device$/d' \
        "$TMP/stderr" > "$TMP/checked-stderr"
      ;;
  esac
  if [ -s "$TMP/checked-stderr" ] || [ -s "$TMP/script-stderr" ]; then
    cat "$TMP/checked-stderr" "$TMP/script-stderr" >&2
    fail "$label: unexpected stderr from tool initialization"
  fi
}

# POSIX sh on macOS is Bash; in that case it legitimately uses the Bash hooks.
# shellcheck disable=SC2016 # Evaluate the checks in each isolated shell.
SHIM_CHECK='for tool in zoxide atuin; do
  [ "$(command -v "$tool")" = "$MISE_DATA_DIR/shims/$tool" ] || { echo "$tool: shim did not resolve" >&2; exit 1; }
done
[ "$(zoxide --version)" = "$SMOKE_ZOXIDE_VERSION" ] || { echo "zoxide: wrong shim version" >&2; exit 1; }
[ "$(atuin --version)" = "$SMOKE_ATUIN_VERSION" ] || { echo "atuin: wrong shim version" >&2; exit 1; }'
# shellcheck disable=SC2016 # These assertions execute inside the child shells.
POSIX_CHECK='[ "$_shell" = sh ] || { echo "sh: wrong shell mode" >&2; exit 1; }
[ -z "${MISE_SHELL-}" ] && [ ! -e "$XDG_CACHE_HOME/shell/mise.sh" ] || { echo "mise: POSIX sh must not activate" >&2; exit 1; }
type z >/dev/null && [ -s "$XDG_CACHE_HOME/shell/zoxide.posix" ] || { echo "zoxide: POSIX hook or cache missing" >&2; exit 1; }'
# shellcheck disable=SC2016 # These assertions execute inside the child shells.
BASH_CHECK='[ "$_shell" = bash ] || { echo "bash: wrong shell mode" >&2; exit 1; }
[ "${MISE_SHELL-}" = bash ] && [ -s "$XDG_CACHE_HOME/shell/mise.bash" ] || { echo "mise: Bash activation or cache missing" >&2; exit 1; }
type z >/dev/null && [ -s "$XDG_CACHE_HOME/shell/zoxide.bash" ] || { echo "zoxide: Bash hook or cache missing" >&2; exit 1; }
type atuin-bind >/dev/null && [ -s "$XDG_CACHE_HOME/shell/atuin.bash" ] || { echo "atuin: Bash hook or cache missing" >&2; exit 1; }'
# shellcheck disable=SC2016 # These assertions execute inside the child shells.
ZSH_CHECK='[ "$_shell" = zsh ] || { echo "zsh: wrong shell mode" >&2; exit 1; }
[ "${MISE_SHELL-}" = zsh ] && [ -s "$XDG_CACHE_HOME/shell/mise.zsh" ] || { echo "mise: Zsh activation or cache missing" >&2; exit 1; }
(( ${+functions[z]} )) && [ -s "$XDG_CACHE_HOME/shell/zoxide.zsh" ] || { echo "zoxide: Zsh hook or cache missing" >&2; exit 1; }
zle -l atuin-search >/dev/null && [ -s "$XDG_CACHE_HOME/shell/atuin.zsh" ] || { echo "atuin: Zsh widget or cache missing" >&2; exit 1; }'
for pass in cold warm; do
  case $(uname -s) in
    Darwin) run_startup "sh ($pass)" "$SHIM_CHECK; $BASH_CHECK" /bin/sh ;;
    Linux) run_startup "sh ($pass)" "$SHIM_CHECK; $POSIX_CHECK" /bin/sh ;;
  esac
  run_startup "bash ($pass)" "$SHIM_CHECK; $BASH_CHECK" "$BASH"
  run_startup "zsh ($pass)" "$SHIM_CHECK; $ZSH_CHECK" "$ZSH"
done

printf 'mise smoke: ok (sh, bash, zsh; cold and warm)\n'
