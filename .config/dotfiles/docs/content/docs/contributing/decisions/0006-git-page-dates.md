+++
title = "ADR-0006: Page dates from Git"
description = "Derive each page's last-updated date from Git at build time; never maintain updated by hand."
weight = 6

[extra]
type = "explanation"
+++

**Status:** Accepted, 2026-11-03.

## Context

Readers judge a page's freshness by its "Last updated" date.
A hand-maintained `updated` field goes stale whenever an edit omits it, and then shows a date the content does not have.
Git already records when each page changed.

## Decision

- Never store `updated` in page front matter.
- `run.sh build` stamps each regular page, in a staged copy, with the author date of the last commit that touched it,
  or today for uncommitted edits.
- Use the author date, not the committer date: rebases and cherry-picks rewrite the committer date.

## Consequences

- Builds need full history.
  CI checks out with `fetch-depth: 0`; a shallow clone warns, and dates stop at the clone boundary.
- Section `_index.md` files carry no date, so content that readers date belongs on regular pages.
- Every commit that touches a page moves its date, including formatting-only changes.
- `docs:serve` shows no dates; pull request builds date changed pages with the merge commit.
- The source tree never changes during a build.

## Details

- [Write documentation](@/docs/contributing/documentation.md#verify)
