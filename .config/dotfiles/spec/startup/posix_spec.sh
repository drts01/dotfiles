# shellcheck shell=sh disable=SC2016 # Commands are evaluated in child shells.

Describe 'OS /bin/sh startup'
Before 'setup_home'
After 'cleanup_home'

posix_syntax() {
  for file in "$ROOT/.profile" "$ROOT/.config/sh/.shrc" \
    "$ROOT"/.config/sh/profile.d/*.sh "$ROOT"/.config/sh/sh.d/*.sh; do
    /bin/sh -n "$file" || return 1
  done
}

sh_login() { run_isolated /bin/sh -l -c "$1"; }

sh_login_interactive() { without_job_control_noise run_isolated /bin/sh -lic "$1"; }

sh_interactive() {
  without_job_control_noise run_isolated env XDG_CONFIG_HOME="$HOME_DIR/.config" \
    XDG_DATA_HOME="$HOME_DIR/.local/share" XDG_STATE_HOME="$HOME_DIR/.local/state" \
    XDG_CACHE_HOME="$HOME_DIR/.cache" ENV="$HOME_DIR/.config/sh/.shrc" \
    /bin/sh -ic "$1"
}

It 'parses the shared profile and interactive files with /bin/sh'
When run posix_syntax
The status should be success
End

It 'loads XDG directories in a login shell'
When run sh_login '[ "$XDG_CONFIG_HOME" = "$HOME/.config" ] && [ "$XDG_DATA_HOME" = "$HOME/.local/share" ]'
The status should be success
End

It 'exports ENV for interactive sh in a login shell'
When run sh_login '[ "$ENV" = "$HOME/.config/sh/.shrc" ]'
The status should be success
End

It 'detects the implementation of the OS shell at login'
When run sh_login 'case ${BASH_VERSION-} in ?*) [ "$_shell" = bash ] ;; *) [ "$_shell" = sh ] ;; esac'
The status should be success
End

It 'provides has and an editor at login'
When run sh_login 'has sh && [ -n "$EDITOR" ]'
The status should be success
End

It 'adds mise shims to the login PATH'
When run sh_login 'case ":$PATH:" in *":$HOME/.local/share/mise/shims:"*) true ;; *) false ;; esac'
The status should be success
End

It 'prepends and deduplicates the login PATH'
When run sh_login 'path_add "$HOME/test-path"; case "$PATH" in "$HOME/test-path:"*) ;; *) exit 1 ;; esac; before=$PATH; path_add "$HOME/test-path"; [ "$PATH" = "$before" ]'
The status should be success
End

It 'loads the shared config via ENV in a non-login interactive shell'
When run sh_interactive 'case ${BASH_VERSION-} in ?*) [ "$_shell" = bash ] ;; *) [ "$_shell" = sh ] ;; esac'
The status should be success
The error should be blank
End

It 'loads the dotfiles alias via ENV'
When run sh_interactive 'alias dotfiles >/dev/null'
The status should be success
The error should be blank
End

It 'makes has reject missing commands via ENV'
When run sh_interactive 'has sh && ! has command-that-does-not-exist'
The status should be success
The error should be blank
End

It 'makes path_add prepend directories via ENV'
When run sh_interactive 'path_add "$HOME/interactive-path"; case "$PATH" in "$HOME/interactive-path:"*) true ;; *) false ;; esac'
The status should be success
The error should be blank
End

It 'enables vi mode in a login OS shell'
When run sh_login_interactive 'set -o | grep -Eq "^vi[[:space:]]+on$"'
The status should be success
The error should be blank
End

It 'enables vi mode via ENV in a non-login interactive OS shell'
When run sh_interactive 'set -o | grep -Eq "^vi[[:space:]]+on$"'
The status should be success
The error should be blank
End

It 'uses the host OS name in a login shell'
When run sh_login 'case $LOCAL_OS in darwin | linux) : ;; *) exit 1 ;; esac; [ "$LOCAL_OS" = "$(uname -s | tr "[:upper:]" "[:lower:]")" ]'
The status should be success
End

It 'only activates mise when /bin/sh is Bash'
fake_bin mise 'printf "%s\n" "$*" >> "$HOME/mise-invocations"; case "$*" in "activate bash") printf ":\n" ;; *) echo "unexpected mise activation: $*" >&2; exit 1 ;; esac'
When run without_job_control_noise run_isolated env PATH="$BIN:/usr/bin:/bin" XDG_CONFIG_HOME="$HOME_DIR/.config" XDG_DATA_HOME="$HOME_DIR/.local/share" XDG_STATE_HOME="$HOME_DIR/.local/state" XDG_CACHE_HOME="$HOME_DIR/.cache" ENV="$HOME_DIR/.config/sh/.shrc" /bin/sh -ic 'case ${BASH_VERSION-} in ?*) grep -qx "activate bash" "$HOME/mise-invocations" ;; *) [ ! -e "$HOME/mise-invocations" ] ;; esac'
The status should be success
The error should be blank
End
End
