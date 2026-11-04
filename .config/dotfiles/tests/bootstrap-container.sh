#!/bin/sh
# Run bootstrap and available ShellSpec tests as a non-root user in clean containers.
# Usage: sh tests/bootstrap-container.sh [image...]
# Engine: CONTAINER_ENGINE, else podman, else docker.
# Container-side setup lives in tests/bootstrap-container-setup.sh.
set -eu

CDPATH=
ROOT=$(cd -- "$(dirname -- "$0")/../../.." && pwd)

if [ $# -eq 0 ]; then
  # buildpack-deps:stable-scm is Debian stable with git and curl preinstalled,
  # which avoids apt on networks that block deb.debian.org.
  # The Chainguard image (Wolfi, dash, git + GNU wget, no curl) covers a curl-free host.
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

if ! command -v mise > /dev/null 2>&1; then
  echo 'ERROR: mise is required to install ShellSpec for container tests.' >&2
  exit 1
fi
if ! SHELLSPEC_HOME=$(mise --cd "$ROOT" where shellspec@latest 2> /dev/null); then
  mise --cd "$ROOT" install --locked shellspec@latest || {
    echo 'ERROR: Could not install locked ShellSpec for container tests.' >&2
    exit 1
  }
  SHELLSPEC_HOME=$(mise --cd "$ROOT" where shellspec@latest) || {
    echo 'ERROR: Could not locate ShellSpec for container tests.' >&2
    exit 1
  }
fi
# Task-scoped tools need not be active in the calling shell.
SHELLSPEC_EXEC=$(find "$SHELLSPEC_HOME" -type f -name shellspec ! -path '*/stub/*' -print)
if [ -z "$SHELLSPEC_EXEC" ] || [ ! -x "$SHELLSPEC_EXEC" ]; then
  echo "ERROR: ShellSpec executable is missing from its mise installation: $SHELLSPEC_HOME" >&2
  exit 1
fi
case $SHELLSPEC_EXEC in
  "$SHELLSPEC_HOME"/*) SHELLSPEC_IN_CONTAINER=/opt/shellspec/${SHELLSPEC_EXEC#"$SHELLSPEC_HOME"/} ;;
  *)
    echo "ERROR: ShellSpec executable is not inside its mise installation: $SHELLSPEC_EXEC" >&2
    exit 1
    ;;
esac

FAILED=""
for image in "$@"; do
  printf '### %s (%s)\n' "$image" "$ENGINE"
  # :ro keeps the test from modifying the checkout; it only reads and pushes from it.
  # A bare --env NAME forwards the host value only when it is set.
  # --user/--entrypoint: images such as Chainguard default to a nonroot user
  # and a non-shell entrypoint (git).
  if ! "$ENGINE" run --rm --user 0 --entrypoint /bin/sh \
    --volume "$ROOT:/src:ro" --volume "$SHELLSPEC_HOME:/opt/shellspec:ro" \
    --env ALPINE_MIRROR --env TEST_BASH \
    "$image" /src/.config/dotfiles/tests/bootstrap-container-setup.sh "$SHELLSPEC_IN_CONTAINER"; then
    FAILED="$FAILED $image"
  fi
done

if [ -n "$FAILED" ]; then
  echo "FAIL:$FAILED" >&2
  exit 1
fi
printf 'bootstrap container tests: ok\n'
