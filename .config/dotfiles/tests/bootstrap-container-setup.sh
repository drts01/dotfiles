#!/bin/sh
# Container-side half of tests/bootstrap-container.sh; expects the checkout at /src.
# Runs as root: installs missing test dependencies, then runs tests/bootstrap.sh
# as an unprivileged user so the bootstrap never relies on root.
# ALPINE_MIRROR (e.g. https://mirrors.edge.kernel.org/alpine) replaces
# dl-cdn.alpinelinux.org on networks that block it.
set -eu

TEST=/src/.config/dotfiles/tests/bootstrap.sh
TEST_USER=tester

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

exec su "$TEST_USER" -s /bin/sh -c "sh $TEST"
