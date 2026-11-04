#!/bin/sh
# Remote entrypoint:
#   curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
# Fetches the repository with git and runs the deploy script from the fetched commit, so the
# script that runs and the dotfiles it deploys always come from the same commit.
# DOTFILES_REF selects a branch, tag, or full commit ID (verified); DOTFILES_SKIP_MISE_INSTALL=1 skips mise;
# DOTFILES_SUBMODULES and DOTFILES_SKIP_SUBMODULES select/exclude plugin groups.

set -eu

REPO_URL="${REPO_URL:-https://github.com/drts01/dotfiles}"
DEST_DIR="${DEST_DIR:-$HOME/.local/share/dotfiles}"
DOTFILES_REF="${DOTFILES_REF:-HEAD}"
DOTFILES_SKIP_MISE_INSTALL="${DOTFILES_SKIP_MISE_INSTALL:-}"

is_commit_id() {
  case "$1" in
    '' | *[!0-9a-f]*) return 1 ;;
  esac
  [ "${#1}" -eq 40 ] || [ "${#1}" -eq 64 ]
}

# mise is optional: a missing downloader or failed install must not block deploying the dotfiles.
install_mise() {
  if command -v curl > /dev/null 2>&1; then
    fetch() { curl --proto '=https' --tlsv1.2 -LsSf --retry 3 "$1"; }
  elif command -v wget > /dev/null 2>&1; then
    # BusyBox wget rejects --tries, --no-hsts, and --https-only.
    fetch() { wget -qO- "$1"; }
  else
    echo "Warning: neither curl nor wget found; continuing without mise." >&2
    return 0
  fi
  echo "Installing mise..."
  # Download to a file: in `fetch | sh` a failed fetch is masked by sh exiting 0.
  if fetch https://mise.run > "$TMP_DIR/mise-install.sh" &&
    MISE_INSTALL_SKIP_IF_EXISTS=1 sh "$TMP_DIR/mise-install.sh"; then
    PATH="$(dirname "${MISE_INSTALL_PATH:-$HOME/.local/bin/mise}"):$PATH"
    export PATH
  else
    echo "Warning: mise installation failed; continuing without mise." >&2
  fi
}

# Wrapped in main so `curl | sh` never executes a partially downloaded script.
main() {
  if ! command -v git > /dev/null 2>&1; then
    echo "ERROR: git is required." >&2
    exit 1
  fi

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  trap 'exit 1' HUP INT TERM

  # Resolve the commit before touching $HOME. Git verifies object IDs while indexing
  # the fetched pack, so a pinned commit ID authenticates every file it contains.
  SOURCE="$TMP_DIR/source.git"
  echo "Fetching $REPO_URL ($DOTFILES_REF)..."
  branch=
  if is_commit_id "$DOTFILES_REF"; then
    object_format=sha1
    if [ "${#DOTFILES_REF}" -eq 64 ]; then object_format=sha256; fi
    git -c init.defaultObjectFormat="$object_format" init -q --bare "$SOURCE"
    git --git-dir="$SOURCE" fetch -q --depth=1 "$REPO_URL" "$DOTFILES_REF"
    rev=FETCH_HEAD
  else
    if [ "$DOTFILES_REF" = HEAD ]; then
      git clone -q --bare --depth=1 "$REPO_URL" "$SOURCE"
    else
      git clone -q --bare --depth=1 --branch "$DOTFILES_REF" "$REPO_URL" "$SOURCE"
    fi
    rev=HEAD
    # Empty for tags: a tag pins the commit, while the install keeps tracking the default branch.
    branch="$(git --git-dir="$SOURCE" symbolic-ref -q --short HEAD || true)"
  fi
  commit="$(git --git-dir="$SOURCE" rev-parse --verify -q "$rev^{commit}")"
  if is_commit_id "$DOTFILES_REF" && [ "$commit" != "$DOTFILES_REF" ]; then
    echo "ERROR: fetched commit $commit does not match DOTFILES_REF $DOTFILES_REF." >&2
    exit 1
  fi
  echo "Resolved $DOTFILES_REF to commit $commit."
  git --git-dir="$SOURCE" show "$commit:.config/dotfiles/mise-tasks/bootstrap.sh" > "$TMP_DIR/bootstrap.sh"

  if [ -z "$DOTFILES_SKIP_MISE_INSTALL" ] && ! command -v mise > /dev/null 2>&1; then
    install_mise
  fi

  REPO_URL="$REPO_URL" DEST_DIR="$DEST_DIR" DOTFILES_COMMIT="$commit" DOTFILES_BRANCH="$branch" \
    sh "$TMP_DIR/bootstrap.sh"

  # Deploy scripts that predate DOTFILES_COMMIT ignore it; never report an unverified install.
  installed="$(git --git-dir="$DEST_DIR" rev-parse --verify -q HEAD || true)"
  if [ "$installed" != "$commit" ]; then
    echo "ERROR: $DEST_DIR is at ${installed:-an unknown commit}, expected $commit." >&2
    echo "Pinned commits must include DOTFILES_COMMIT support in mise-tasks/bootstrap.sh." >&2
    exit 1
  fi
}

main "$@"
