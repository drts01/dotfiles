+++
title = "ADR-0005: Diátaxis and a canonical site"
description = "Give each page one Diátaxis type set by its section; treat the site as canonical and make READMEs link to it."
weight = 5

[extra]
type = "explanation"
+++

**Status:** Accepted, 2026-11-03.
Site made canonical for the contributor workflow on 2026-11-04.

## Context

The first site mixed installation steps, internals, and reference tables on long pages,
so a new reader could not reach a working install from one page.
The contributor workflow existed twice, in `.github/CONTRIBUTING.md` and on the site, and the copies drifted.

## Decision

- Give every page exactly one [Diátaxis](https://diataxis.fr/) type, fixed by its section: tutorials in `start/`,
  how-to guides in `how-to/`, explanations in `concepts/`, and reference in `reference/`.
  `contributing/` holds developer how-to and reference pages; `contributing/decisions/` holds these records.
- Treat the site as the canonical documentation.
  READMEs and `.github/CONTRIBUTING.md` carry landing content, a short summary, and links.
- Keep `.github/SECURITY.md` canonical for the security policy, because GitHub reads it from there;
  the site links to it.
- Accept breaking URL changes without `aliases`; record them in the [changelog](@/docs/reference/changelog.md).

## Consequences

- `docs:check` and `docs:build` fail when a page lacks a type, its type does not match its section,
  or it sits outside a section.
- A page that needs two types splits into two pages.
- User-facing sections state user requirements only; developer requirements appear only under `contributing/`.
- GitHub renders `.github/*.md` without the site's includes or links, so those files stay short and point to the site.
- Moving a page updates every internal `@/` link in the same change; the build fails on a broken link.

## Details

- [Write documentation](@/docs/contributing/documentation.md#choose-the-page-type)
