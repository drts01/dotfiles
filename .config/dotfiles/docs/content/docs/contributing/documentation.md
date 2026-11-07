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

| Section                   | `extra.type`            | Contains                                      |
| ------------------------- | ----------------------- | --------------------------------------------- |
| `start/`                  | `tutorial`              | One linear path with checkpoints; no options  |
| `how-to/`                 | `how-to`                | One task: prerequisites, steps, verify, undo  |
| `concepts/`               | `explanation`           | Design and tradeoffs; no procedures           |
| `reference/`              | `reference`             | Tables and values; no procedures or rationale |
| `contributing/`           | `how-to` or `reference` | Developer tasks; may require mise             |
| `contributing/decisions/` | `explanation`           | Architecture decision records                 |

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

## Record a decision

Write an architecture decision record (ADR) when a choice constrains future contributors
and reversing it costs more than one pull request.

| Information                                     | Where                                      |
| ----------------------------------------------- | ------------------------------------------ |
| Why the system is built this way                | ADR in `contributing/decisions/`           |
| How a feature works and its tradeoffs for users | Concepts page on that topic                |
| What changed and how to migrate                 | [Changelog](@/docs/reference/changelog.md) |

1. Take the next free number from [Decisions](@/docs/contributing/decisions/_index.md).
2. Create `contributing/decisions/NNNN-short-name.md` from the template:

   ```markdown
   +++
   title = "ADR-NNNN: Short noun phrase"
   description = "One sentence that states the decision."
   weight = N

   [extra]
   type = "explanation"
   +++

   **Status:** Accepted, YYYY-MM-DD.

   ## Context

   Forces and constraints that require a choice; facts, not arguments.

   ## Decision

   The choice, in imperative sentences.

   ## Consequences

   - What becomes easier, harder, or required of contributors.
   - When to revisit the decision.

   ## Details

   - Link to the concepts or contributing page that explains the topic.
   ```

3. Add a row to the status table in `contributing/decisions/_index.md`.
4. Optionally end the related concepts page with `Decisions:` and a link to the record.
   The concepts page never repeats the record's rationale; the record never repeats the page's detail.

Fix typos and links in place.
To change an accepted decision, supersede it instead of editing it:

1. Add a new record whose status line reads `Accepted, YYYY-MM-DD. Supersedes ADR-NNNN.`
2. In the old record, change only the status line to `Superseded by ADR-NNNN, YYYY-MM-DD.`, linking the new record.
3. Update both rows in the status table.

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
The Vale hook runs on staged documentation before each commit;
`--all-files` checks every tracked Markdown file except agent prompts and talk notes.
The `House` style also rejects patterns common in generated text: stock phrases, hype vocabulary,
sentence-opening connectives, `not just X, but Y` framing, em dashes, and emoji.
Add terms that Vale reports as misspelled to `.config/vale/styles/config/vocabularies/House/accept.txt`.
`docs:check` and `docs:build` fail when a page lacks `extra.type` or its type does not match its section.
In a clone, they also fail when a `source` link points at an untracked path,
or when a tracked entry under `.config/` has no row in File layout.
`docs:build` stamps a temporary copy; it does not change the source files.
