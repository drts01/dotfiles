+++
title = "ADR-0004: Zola and devlab-theme"
description = "Build the documentation site with Zola and devlab-theme; re-evaluate Zensical only on stated triggers."
weight = 4

[extra]
type = "explanation"
+++

**Status:** Accepted, 2026-09-10.
Re-evaluated against Zensical on 2026-11-03, 2026-11-04, and 2026-11-07; kept.

## Context

The site needs search, a nested sidebar, Git-derived page dates, link and anchor checks,
and deployment to GitHub Pages from CI.
The development toolchain already pins tools through mise; a generator that adds a language runtime enlarges it.

| Option          | Verdict  | Reason                                                            |
| --------------- | -------- | ----------------------------------------------------------------- |
| Zola            | Chosen   | Single binary through mise; theme, search, and CI deploy in place |
| Zensical        | Revisit  | Adds Python 3.11 or later and a full migration                    |
| Starlight       | Rejected | Adds Node and Astro, and an MDX migration                         |
| Hugo and Docsy  | Rejected | Built for multi-version, multi-language projects                  |
| MkDocs Material | Rejected | Its maintainers moved their effort to Zensical                    |

## Decision

Build the site with Zola 0.23 and devlab-theme, pinned as a submodule at a release tag.
The shared `mise.lock` pins Zola.

## Consequences

- Zola cannot include files from outside the site directory.
  Drift control relies on checks in `run.sh`, not on shared Markdown includes.
- A Zensical migration would rewrite the theme, date stamping, page type checks, `docs:*` tasks, the Pages workflow,
  Vale paths, and every internal `@/` link.
- Theme upgrades follow the theme's upgrade guides; local templates are limited to components.
- Re-evaluate Zensical when any of these holds:
  - Reference pages need configuration excerpts for three or more tools.
  - The site needs content from outside `docs/` in more than two places.
  - The site needs versioned docs, or exceeds about 40 pages.
- Release maturity is not a trigger.

## Details

- [Write documentation](@/docs/contributing/documentation.md)
