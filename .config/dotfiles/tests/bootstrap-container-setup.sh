#!/bin/sh
# Container-side half of tests/bootstrap-container.sh; expects the checkout at /src.
# Runs as root: installs missing test dependencies, then runs bootstrap and
# available ShellSpec tests as an unprivileged user.
# ALPINE_MIRROR (e.g. https://mirrors.edge.kernel.org/alpine) replaces
# dl-cdn.alpinelinux.org on networks that block it.
set -eu

TEST=/src/.config/dotfiles/tests/bootstrap.sh
SHELLSPEC=${1:?ShellSpec executable path is required}
TEST_USER=tester

if [ ! -x "$SHELLSPEC" ]; then
  echo "ERROR: Mounted ShellSpec executable is missing: $SHELLSPEC" >&2
  exit 1
fi

has() { command -v "$1" > /dev/null 2>&1; }

# Images that already ship the tools (buildpack-deps, Chainguard) skip the
# package manager, so the test also runs on networks that block distro mirrors.
if has git && { has curl || has wget; } && has su; then
  :
elif has apk; then
  if [ -n "${ALPINE_MIRROR:-}" ]; then
    sed -i "s|^https://dl-cdn.alpinelinux.org/alpine|$ALPINE_MIRROR|" /etc/apk/repositories
  fi
  apk add --no-cache --quiet curl git
elif has apt-get; then
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -qq --yes --no-install-recommends \
    ca-certificates curl git > /dev/null
elif has dnf; then
  dnf install --quiet --assumeyes git shadow-utils util-linux > /dev/null
else
  echo "ERROR: Unsupported image: missing git, curl/wget, or su, and no apk, apt-get, or dnf." >&2
  exit 1
fi

if ! id "$TEST_USER" > /dev/null 2>&1; then
  if has useradd; then
    useradd --create-home "$TEST_USER"
  else
    adduser -D "$TEST_USER"
  fi
fi

case ${TEST_BASH:-auto} in
  required)
    if ! has bash; then
      echo "FAIL: Bash is required by this image's CI configuration." >&2
      exit 1
    fi
    RUN_BASH=1
    ;;
  skip) RUN_BASH=0 ;;
  auto)
    if has bash; then RUN_BASH=1; else RUN_BASH=0; fi
    ;;
  *)
    echo "ERROR: TEST_BASH must be required, skip, or auto." >&2
    exit 1
    ;;
esac

# su preserves the image's cwd; Chainguard's /home/git is inaccessible to tester.
# The checkout is read-only, so disable ShellSpec's failure quick-log writes.
if [ "$RUN_BASH" -eq 1 ]; then
  exec su "$TEST_USER" -s /bin/sh -c "cd && sh $TEST && cd /src/.config/dotfiles && $SHELLSPEC --no-quick --shell sh spec/unit spec/startup/posix_spec.sh spec/startup/cleanup_spec.sh && $SHELLSPEC --no-quick --shell bash spec/unit spec/startup/bash_spec.sh"
fi
exec su "$TEST_USER" -s /bin/sh -c "cd && sh $TEST && cd /src/.config/dotfiles && $SHELLSPEC --no-quick --shell sh spec/unit spec/startup/posix_spec.sh spec/startup/cleanup_spec.sh"
