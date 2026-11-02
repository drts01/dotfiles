# shellcheck shell=sh disable=SC2016 # Stubs evaluate their bodies in child shells.

Describe 'source_cache in the selected shell'
Before 'setup_home'
After 'cleanup_home'

prepare_cache() {
  _shell=
  PATH="$BIN:$PATH"
  SOURCE_CACHE_COUNT=$TEST_TMP/count
  export PATH SOURCE_CACHE_COUNT
  CACHE=$TEST_TMP/cache/init.sh
  fake_bin test-init 'printf x >> "$SOURCE_CACHE_COUNT"; printf "SOURCE_CACHE_VALUE=%s\n" "$1"'
  # shellcheck disable=SC1090
  . "$ROOT/.config/sh/profile.d/10_functions.sh"
}

missing_generator() {
  prepare_cache
  source_cache "$TEST_TMP/missing" command-that-does-not-exist
  [ ! -e "$TEST_TMP/missing" ] && [ -z "${_sc_file-}${_sc_bin-}${_sc_tmp-}" ]
}

generate_cache() {
  prepare_cache
  source_cache "$CACHE" test-init one
  [ "$SOURCE_CACHE_VALUE" = one ] && [ -s "$CACHE" ] && [ "$(cat "$SOURCE_CACHE_COUNT")" = x ]
}

reuse_cache() {
  prepare_cache
  source_cache "$CACHE" test-init one
  SOURCE_CACHE_VALUE=
  source_cache "$CACHE" test-init two
  [ "$SOURCE_CACHE_VALUE" = one ] && [ "$(cat "$SOURCE_CACHE_COUNT")" = x ]
}

regenerate_cache() {
  prepare_cache
  source_cache "$CACHE" test-init one
  touch -t 200001010101 "$CACHE"
  touch -t 200101010101 "$BIN/test-init"
  source_cache "$CACHE" test-init two
  [ "$SOURCE_CACHE_VALUE" = two ] && [ "$(cat "$SOURCE_CACHE_COUNT")" = xx ]
}

preserve_cache() {
  prepare_cache
  source_cache "$CACHE" test-init one
  touch -t 200001010101 "$CACHE"
  fake_bin test-init 'printf x >> "$SOURCE_CACHE_COUNT"; exit 1'
  touch -t 200101010101 "$BIN/test-init"
  SOURCE_CACHE_VALUE=
  source_cache "$CACHE" test-init ignored
  [ "$SOURCE_CACHE_VALUE" = one ] &&
    [ "$(cat "$SOURCE_CACHE_COUNT")" = xx ] &&
    [ ! -e "$CACHE.$$" ] && [ -z "${_sc_file-}${_sc_bin-}${_sc_tmp-}" ]
}

compile_zsh_cache() {
  prepare_cache
  [ "$_shell" = zsh ] || return 1
  source_cache "$CACHE" test-init one
  [ -s "$CACHE.zwc" ]
}

It 'does not create a file or leak variables when the command is missing'
When run missing_generator
The status should be success
End

It 'generates, writes, and sources a new cache'
When run generate_cache
The status should be success
End

It 'sources a cache hit without rerunning its generator'
When run reuse_cache
The status should be success
End

It 'regenerates a cache older than its generator'
When run regenerate_cache
The status should be success
End

It 'keeps the prior cache and removes the temp file after generator failure'
When run preserve_cache
The status should be success
End

not_zsh() { [ -z "${ZSH_VERSION-}" ]; }
Skip if 'Zsh byte compilation only applies to Zsh' not_zsh
It 'byte-compiles a generated cache under Zsh'
When run compile_zsh_cache
The status should be success
End
End
