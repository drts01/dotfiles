#!/bin/sh
# Build or preview the documentation site from a development clone.
#   sh run.sh build [zola build options]  Build into ./public with git-derived page dates.
#   sh run.sh check [zola check options]  Check page types and internal links, including anchors.
#   sh run.sh serve [zola serve options]  Serve the source tree with live reload (no dates).
# Pages never carry a hand-maintained `updated` field: the build stamps each page with the
# date of the last commit that touched it, or today for uncommitted edits.
# The build also fails when a docs page lacks the Diátaxis `type` its section requires,
# when a {{<source>}} link points at an untracked path, or when a tracked .config entry lacks a file-layout row.
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

# Author date: rebases and cherry-picks rewrite the committer date but keep when the content changed.
page_date() {
  if [ -n "$(git -C "$DOCS_DIR" status --porcelain -- "$1")" ]; then
    date +%Y-%m-%d
  else
    git -C "$DOCS_DIR" log -1 --format=%as -- "$1"
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

# Each docs page declares its Diátaxis type as `type` under `[extra]`; its section fixes the allowed types.
allowed_types() {
  case "$1" in
    docs/start/*/* | docs/how-to/*/* | docs/concepts/*/* | docs/reference/*/* | docs/contributing/*/*) ;;
    docs/start/*) echo tutorial ;;
    docs/how-to/*) echo how-to ;;
    docs/concepts/*) echo explanation ;;
    docs/reference/*) echo reference ;;
    docs/contributing/*) echo how-to reference ;;
  esac
}

page_type() {
  awk '
    NR == 1 { if ($0 != "+++") exit; next }
    $0 == "+++" { exit }
    /^\[/ { table = $0; next }
    table == "[extra]" && /^type[ \t]*=/ {
      sub(/^type[ \t]*=[ \t]*"/, ""); sub(/".*/, ""); print; exit
    }
  ' "$1"
}

check_types() {
  find "$DOCS_DIR/content/docs" -name '*.md' ! -name '_index.md' | sort | {
    failed=0
    while IFS= read -r page; do
      relative=${page#"$DOCS_DIR"/content/}
      allowed=$(allowed_types "$relative")
      if [ -z "$allowed" ]; then
        echo "ERROR: $relative must sit directly in docs/start, how-to, concepts, reference, or contributing." >&2
        failed=1
        continue
      fi
      type=$(page_type "$page")
      case " $allowed " in
        *" ${type:-none} "*) ;;
        *)
          echo "ERROR: $relative has [extra] type '${type:-}'; expected: $allowed." >&2
          failed=1
          ;;
      esac
    done
    exit "$failed"
  }
}

LAYOUT_PAGE="$DOCS_DIR/content/docs/reference/file-layout.md"

source_paths() {
  grep -rhoE '\{\{< *source path="[^"]+"' "$@" | sed 's/.*path="//; s/"$//' | sort -u
}

# Source links must resolve on the forge, and file-layout.md must list every tool under .config.
# An installed $HOME has no work tree to compare against, so the check runs only in a clone.
check_sources() {
  if ! in_clone; then
    echo "Warning: not a git work tree; skipping source link checks." >&2
    return 0
  fi
  root=$(git -C "$DOCS_DIR" rev-parse --show-toplevel)
  layout=$(source_paths "$LAYOUT_PAGE")
  failed=0
  for path in $(source_paths "$DOCS_DIR/content"); do
    # Submodules are gitlinks: match them without the trailing slash.
    if [ -z "$(git -C "$root" ls-files -- "${path%/}")" ]; then
      echo "ERROR: {{<source>}} links to untracked path '$path'." >&2
      failed=1
    fi
  done
  for entry in $(git -C "$root" ls-files -- .config | awk -F/ 'NF > 2 { print $1 "/" $2 "/"; next } { print }' | sort -u); do
    if ! printf '%s\n' "$layout" | grep -qxF -- "$entry"; then
      echo "ERROR: ${LAYOUT_PAGE#"$DOCS_DIR"/} has no {{<source path=\"$entry\" />}} row." >&2
      failed=1
    fi
  done
  return "$failed"
}

build() {
  ensure_theme
  check_types
  check_sources
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

# Plain checks need no dates; the build stamps them into a staged copy.
check() {
  ensure_theme
  check_types
  check_sources
  cd "$DOCS_DIR"
  exec zola check "$@"
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
  check) check "$@" ;;
  serve) serve "$@" ;;
  *)
    echo "usage: sh run.sh build|check|serve [zola options]" >&2
    exit 2
    ;;
esac
