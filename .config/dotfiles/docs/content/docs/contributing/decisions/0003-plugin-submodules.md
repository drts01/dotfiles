+++
title = "ADR-0003: Plugin submodules"
description = "Pin third-party plugins with Git submodules, initialized per group only when the group's tool is on PATH."
weight = 3

[extra]
type = "explanation"
+++

**Status:** Accepted, 2026-11-03.

## Context

Zsh, Neovim, and Lua plugins and the documentation theme come from third-party repositories.
Vendored copies lose upstream history; a plugin manager adds a dependency and fetches unpinned code at startup.
A machine without Neovim gains nothing from Neovim plugins, and only a site build needs the theme.

## Decision

Pin each plugin and theme as a shallow Git submodule, grouped by the tool that uses it.

- By default (`auto`), the installer initializes a group only when its tool is on `PATH`.
- `DOTFILES_SUBMODULES` and `DOTFILES_SKIP_SUBMODULES` select or exclude groups for one run.
- The `docs` group is never automatic; select it explicitly or with `all`.

## Consequences

- A pinned dotfiles commit fixes every plugin version through its gitlink.
  Plugin updates are commits, reviewed like any other change.
- The upstream hosts must keep serving the pinned commits; a deleted repository breaks the install, not its integrity.
- Submodules pin source such as plugins and themes; they are not a package manager for binaries, which come from mise.
- Shell and editor configurations must start without their plugins.
- Add a plugin as a shallow submodule under its group's path.
  A new group needs a case in `mise-tasks/bootstrap.sh`
  and a row in [Plugin groups](@/docs/reference/environment.md#plugin-groups).
- `git submodule` requires the current directory to be inside `$HOME`, even with `--work-tree`.

## Details

- [Choose plugin groups](@/docs/how-to/choose-plugin-groups.md)
- [Security model](@/docs/concepts/security.md#trust-boundaries)
