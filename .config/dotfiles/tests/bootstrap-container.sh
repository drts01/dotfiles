#!/bin/sh
# Run tests/bootstrap.sh as a non-root user inside clean containers.
# Usage: sh tests/bootstrap-container.sh [image...]
# Engine: CONTAINER_ENGINE, else podman, else docker.
# Container-side setup lives in tests/bootstrap-container-setup.sh.
set -eu

CDPATH=
ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)

if [ $# -eq 0 ]; then
  # buildpack-deps:stable-scm is Debian stable with git and curl preinstalled,
  # which avoids apt on networks that block deb.debian.org.
  # The Chainguard image (Wolfi, dash, git + GNU wget, no curl) covers the wget path.
  set -- buildpack-deps:stable-scm alpine:latest fedora:latest \
    cgr.dev/chainguard/git:latest-dev
fi

ENGINE="${CONTAINER_ENGINE:-}"
if [ -z "$ENGINE" ]; then
  for candidate in podman docker; do
    if command -v "$candidate" > /dev/null 2>&1; then
      ENGINE=$candidate
      break
    fi
  done
fi
if [ -z "$ENGINE" ]; then
  echo "ERROR: Neither podman nor docker found; set CONTAINER_ENGINE." >&2
  exit 1
fi

FAILED=""
for image in "$@"; do
  printf '### %s (%s)\n' "$image" "$ENGINE"
  # :ro keeps the test from modifying the checkout; it only reads and pushes from it.
  # A bare --env NAME forwards the host value only when it is set.
  # --user/--entrypoint: images such as Chainguard default to a nonroot user
  # and a non-shell entrypoint (git).
  if ! "$ENGINE" run --rm --user 0 --entrypoint /bin/sh \
    --volume "$ROOT:/src:ro" --env ALPINE_MIRROR \
    "$image" /src/.config/dotfiles/tests/bootstrap-container-setup.sh; then
    FAILED="$FAILED $image"
  fi
done

if [ -n "$FAILED" ]; then
  echo "FAIL:$FAILED" >&2
  exit 1
fi
printf 'bootstrap container tests: ok\n'
