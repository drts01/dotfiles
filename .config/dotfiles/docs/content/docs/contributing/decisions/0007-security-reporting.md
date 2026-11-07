+++
title = "ADR-0007: Private vulnerability reporting"
description = "Accept security reports only through GitHub private vulnerability reporting, governed by .github/SECURITY.md."
weight = 7

[extra]
type = "explanation"
+++

**Status:** Accepted, 2026-11-04.

## Context

The installer runs from `curl | sh` and changes shell, SSH, and Git settings in `$HOME`.
A public issue discloses a vulnerability before a fix exists.
The project has one maintainer, no releases, and no mail infrastructure for private reports.

## Decision

Accept vulnerability reports only through
[GitHub private vulnerability reporting](https://github.com/drts01/dotfiles/security/advisories/new).
`.github/SECURITY.md` defines the scope, the supported version, and what a report includes;
the [security model](@/docs/concepts/security.md) links to it.

## Consequences

- Reporters need a GitHub account.
- Private vulnerability reporting must stay enabled in the repository settings; the policy link fails without it.
- Only the latest commit on `trunk` receives fixes.
  Fixes land on `trunk` and appear in the [changelog](@/docs/reference/changelog.md); without releases,
  nothing is backported.
- Plugin submodules, mise, prek, and the documentation theme are out of scope; reports go upstream.
- Response is best effort, without a promised response time.

## Details

- [Security policy](https://github.com/drts01/dotfiles/security/policy)
- [Security model](@/docs/concepts/security.md)
