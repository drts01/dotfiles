+++
title = "Decisions"
description = "Architecture decision records: why the system is built this way, and when to revisit each choice."
weight = 40
sort_by = "weight"
template = "docs.html"
page_template = "doc-page.html"
+++

Each record states one decision that constrains future contributors: its context, the choice, and its consequences.
Concepts pages explain how a feature works; records explain why it exists and when to revisit it.

| Record                                                                    | Decision                                                           | Status   | Decided    |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------ | -------- | ---------- |
| [ADR-0001](@/docs/contributing/decisions/0001-bare-repository.md)         | Use a Git bare repository with `$HOME` as the work tree            | Accepted | 2021-10-02 |
| [ADR-0002](@/docs/contributing/decisions/0002-minimal-requirements.md)    | Require only Git and POSIX `sh`; mise is optional and additive     | Accepted | 2026-11-03 |
| [ADR-0003](@/docs/contributing/decisions/0003-plugin-submodules.md)       | Pin third-party plugins with submodules, opt-in per tool on `PATH` | Accepted | 2026-11-03 |
| [ADR-0004](@/docs/contributing/decisions/0004-site-generator.md)          | Build the site with Zola and devlab-theme                          | Accepted | 2026-09-10 |
| [ADR-0005](@/docs/contributing/decisions/0005-documentation-structure.md) | Structure docs with Diátaxis; the site is canonical; READMEs link  | Accepted | 2026-11-03 |
| [ADR-0006](@/docs/contributing/decisions/0006-git-page-dates.md)          | Derive page dates from Git; never hand-maintain `updated`          | Accepted | 2026-11-03 |
| [ADR-0007](@/docs/contributing/decisions/0007-security-reporting.md)      | Accept vulnerability reports through GitHub private reporting      | Accepted | 2026-11-04 |

## Statuses

| Status     | Meaning                                                        |
| ---------- | -------------------------------------------------------------- |
| Accepted   | Binding on every change; replace it only by superseding        |
| Superseded | Replaced by a newer record; the status line links to it        |
| Deprecated | No longer applies, and no record replaces it                   |

A record merges as Accepted; its pull request is the proposal.
To add or supersede a record, see [Record a decision](@/docs/contributing/documentation.md#record-a-decision).
