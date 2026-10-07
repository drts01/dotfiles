#!/bin/sh
set -eu

ROOT=$1
TMP=$2
FUNCTIONS="$ROOT/.config/sh/profile.d/10_functions.sh"
BIN="$TMP/bin"
CACHE="$TMP/cache/init.$(basename "$0")"
COUNT="$TMP/count"

mkdir -p "$BIN"
# shellcheck disable=SC2016
printf '%s\n' \
  '#!/bin/sh' \
  'printf x >> "$SOURCE_CACHE_COUNT"' \
  'printf '\''SOURCE_CACHE_VALUE=%s\n'\'' "$1"' > "$BIN/test-init"
chmod +x "$BIN/test-init"

PATH="$BIN:$PATH"
SOURCE_CACHE_COUNT=$COUNT
_shell=
export PATH SOURCE_CACHE_COUNT
# shellcheck disable=SC1090
. "$FUNCTIONS"

source_cache "$TMP/missing" command-that-does-not-exist
[ ! -e "$TMP/missing" ]
[ -z "${_sc_file-}${_sc_bin-}" ]

source_cache "$CACHE" test-init one
[ "$SOURCE_CACHE_VALUE" = one ]
[ "$(cat "$COUNT")" = x ]

SOURCE_CACHE_VALUE=
source_cache "$CACHE" test-init two
[ "$SOURCE_CACHE_VALUE" = one ]
[ "$(cat "$COUNT")" = x ]

sleep 1
touch "$BIN/test-init"
source_cache "$CACHE" test-init two
[ "$SOURCE_CACHE_VALUE" = two ]
[ "$(cat "$COUNT")" = xx ]

sleep 1
# shellcheck disable=SC2016
printf '%s\n' \
  '#!/bin/sh' \
  'printf x >> "$SOURCE_CACHE_COUNT"' \
  'exit 1' > "$BIN/test-init"
chmod +x "$BIN/test-init"
SOURCE_CACHE_VALUE=
source_cache "$CACHE" test-init ignored
[ "$SOURCE_CACHE_VALUE" = two ]
[ "$(cat "$COUNT")" = xxx ]
[ ! -e "$CACHE.$$" ]

if [ "$_shell" = zsh ]; then
  [ -s "$CACHE.zwc" ]
fi
