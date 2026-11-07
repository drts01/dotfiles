+++
title = "Write documentation"
description = "Add or change a page on this site: page types, front matter, links, and checks."
weight = 30

[extra]
type = "how-to"
+++

Add a page that fits the site structure and passes the build.

## Prerequisites

- A [development clone](@/docs/contributing/development.md).

## Choose the page type

The site follows [Diátaxis](https://diataxis.fr/): each page has exactly one type, and its section sets the type.

| Section         | `extra.type`               | Contains                                         |
| --------------- | -------------------------- | ------------------------------------------------ |
| `start/`        | `tutorial`                 | One linear path with checkpoints; no options     |
| `how-to/`       | `how-to`                   | One task: prerequisites, steps, verify, undo     |
| `concepts/`     | `explanation`              | Design and tradeoffs; no procedures              |
| `reference/`    | `reference`                | Tables and values; no procedures or rationale    |
| `contributing/` | `how-to` or `reference`    | Developer tasks; may require mise                |

Pages outside `contributing/` state user requirements only: Git and a POSIX `sh`, with mise optional.

## Add the page

1. Create a regular page under `.config/dotfiles/docs/content/docs/<section>/`, never an `_index.md`.
2. Add front matter:

   ```toml
   +++
   title = "Choose plugin groups"
   description = "One sentence that states the outcome."
   weight = 20

   [extra]
   type = "how-to"
   +++
   ```

3. Link other pages by source path, for example `@/docs/how-to/update.md#verify`.
   `docs:check` fails on a missing page or anchor; `docs:build` checks pages only.
4. Link a tracked repository file or directory with the `source` component; end a directory with `/`:

   {% raw %}

   ```jinja
   {{<source path=".config/helix/" />}}
   ```

   {% endraw %}

   Link to complete configuration files; do not paste them into pages.
   Quote a setting only beside the text that explains it.
   Add a page for a tool only when it has behavior to explain;
   otherwise its row in [File layout](@/docs/reference/file-layout.md) is enough.

Do not add `updated`; the build stamps each page with the author date of its last commit,
or today for uncommitted edits.

## Verify

From a configured development clone:

```bash
prek run --config .config/dotfiles/prek.toml --all-files vale
mise run docs:check -- --skip-external-links
mise run docs:build
```

| Task         | Purpose                                  | Page dates               | Link checks                                 |
| ------------ | ---------------------------------------- | ------------------------ | ------------------------------------------- |
| Vale hook    | Check prose against the Vale house style | None                     | None                                        |
| `docs:check` | Validate page types, links, and anchors  | None                     | Internal and external by default            |
| `docs:build` | Build the publishable site               | Git-derived author dates | Zola build checks page targets, not anchors |
| `docs:serve` | Preview with live reload                 | None                     | None                                        |

Use `--skip-external-links` with `docs:check` for a fast offline-friendly check; omit it to check external links too.
The Vale hook runs on staged documentation before each commit; `--all-files` checks every tracked file.
`docs:check` and `docs:build` fail when a page lacks `extra.type` or its type does not match its section.
In a clone, they also fail when a `source` link points at an untracked path,
or when a tracked entry under `.config/` has no row in File layout.
`docs:build` stamps a temporary copy; it does not change the source files.
