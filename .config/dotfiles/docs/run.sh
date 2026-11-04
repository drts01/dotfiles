#!/bin/sh
# Build or preview the documentation site from a development clone.
#   sh site.sh build [zola build options]  Build into ./public with git-derived page dates.
#   sh site.sh serve [zola serve options]  Serve the source tree with live reload (no dates).
# Pages never carry a hand-maintained `updated` field: the build stamps each page with the
# date of the last commit that touched it, or today for uncommitted edits.
set -eu

CDPATH=
DOCS_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
THEME_DIR="$DOCS_DIR/themes/devlab-theme"

in_clone() { git -C "$DOCS_DIR" rev-parse --is-inside-work-tree > /dev/null 2>&1; }

# The theme is a submodule: initialize it in a clone; an installed $HOME requests it explicitly.
ensure_theme() {
  if [ -f "$THEME_DIR/theme.toml" ]; then return 0; fi
  if in_clone; then
    echo "Initializing the documentation theme submodule..."
    git -C "$DOCS_DIR" submodule update --init -- themes
  else
    echo "ERROR: the documentation theme is missing at $THEME_DIR." >&2
    echo "Install it with: DOTFILES_SUBMODULES=docs sh ~/.config/dotfiles/mise-tasks/bootstrap.sh" >&2
    exit 1
  fi
}

page_date() {
  if [ -n "$(git -C "$DOCS_DIR" status --porcelain -- "$1")" ]; then
    date +%Y-%m-%d
  else
    git -C "$DOCS_DIR" log -1 --format=%cs -- "$1"
  fi
}

# Replace any `updated` key in the TOML front matter with the given date.
stamp_page() {
  awk -v d="$2" '
    NR == 1 && $0 == "+++" { print; print "updated = " d; fm = 1; next }
    fm && $0 == "+++" { fm = 0 }
    fm && /^updated[ \t]*=/ { next }
    { print }
  ' "$1" > "$1.tmp"
  mv "$1.tmp" "$1"
}

stamp_dates() {
  if ! in_clone; then
    echo "Warning: not a git work tree; building without page dates." >&2
    return 0
  fi
  if [ "$(git -C "$DOCS_DIR" rev-parse --is-shallow-repository)" = true ]; then
    echo "Warning: shallow clone; page dates stop at the clone boundary. Fetch full history." >&2
  fi
  find "$1/content" -name '*.md' ! -name '_index.md' | while IFS= read -r page; do
    date=$(page_date "$DOCS_DIR/${page#"$1"/}")
    if [ -n "$date" ]; then stamp_page "$page" "$date"; fi
  done
}

build() {
  ensure_theme
  stage=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-docs.XXXXXX")
  trap 'rm -rf "$stage"' EXIT
  trap 'exit 1' HUP INT TERM
  # Stamp a copy so the source tree, and its git status, never change during a build.
  for entry in zola.toml content static templates sass themes; do
    if [ -e "$DOCS_DIR/$entry" ]; then cp -R "$DOCS_DIR/$entry" "$stage/"; fi
  done
  stamp_dates "$stage"
  zola --root "$stage" build --output-dir "$DOCS_DIR/public" --force "$@"
}

serve() {
  ensure_theme
  cd "$DOCS_DIR"
  exec zola serve "$@"
}

command=${1-}
if [ "$#" -gt 0 ]; then shift; fi
case "$command" in
  build) build "$@" ;;
  serve) serve "$@" ;;
  *)
    echo "usage: sh site.sh build|serve [zola options]" >&2
    exit 2
    ;;
esac
