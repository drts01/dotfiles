+++
title = "ADR-0002: Git and POSIX sh only"
description = "Require only Git and a POSIX sh to install and use the dotfiles; mise is optional and additive."
weight = 2

[extra]
type = "explanation"
+++

**Status:** Accepted, 2026-11-03.

## Context

The install target may lack root access, a package manager, or network access beyond the Git host.
Every required tool is a precondition the user must meet before the dotfiles help them. mise installs useful tools,
tasks, and hooks, but it is a third-party download outside commit verification.

## Decision

Require only Git and a POSIX `sh` to install, update, and use the dotfiles.

- mise is optional and additive: it adds tools, tasks, and hooks on top of a working install.
- The installer warns and continues when it cannot fetch or install mise.
- curl fetches the one-line entrypoint; the installer needs curl or wget only to fetch mise.
  The Git-only install needs neither.

## Consequences

- The entrypoint and deploy script stay POSIX `sh`, with no Bash features and no language runtime.
  Review every change to `bootstrap.sh` and `mise-tasks/bootstrap.sh` against this constraint.
- Every installed task that users need has a script equivalent; see [mise tasks](@/docs/reference/tasks.md).
- User-facing pages state Git and a POSIX `sh` as the only requirements and never describe mise as required.
- The constraint covers users, not contributors: development requires mise, and only `contributing/` pages say so.
- `DOTFILES_SKIP_MISE_INSTALL=1` removes the one download that a commit pin does not cover.

## Details

- [How the installer works](@/docs/concepts/bootstrap-flow.md)
- [Install without mise](@/docs/how-to/install-without-mise.md)
- [Security model](@/docs/concepts/security.md#what-a-pin-does-not-cover)
