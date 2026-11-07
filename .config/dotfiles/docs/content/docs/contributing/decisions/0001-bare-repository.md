+++
title = "ADR-0001: Bare repository in $HOME"
description = "Use a Git bare repository with $HOME as the work tree."
weight = 1

[extra]
type = "explanation"
+++

**Status:** Accepted, 2021-10-02.

## Context

The dotfiles must work on machines the user does not control: no root access, no package manager,
and an afternoon to get productive.
Most dotfile setups keep a clone in a project directory and link or render each file into `$HOME`.
That model needs a manager, a deploy step after every edit, and knowledge of the manager's layout or template syntax.

## Decision

Track the dotfiles in a bare Git repository at `~/.local/share/dotfiles`, with `$HOME` as its work tree.

- Deploy real files in place: no symlinks, no templates, no apply step.
- Pass `--work-tree="$HOME"` on every command; keep `core.bare=true` and never store `core.worktree`.
- Expose the repository through one `dotfiles` alias; plain `git` in `$HOME` finds no repository.

## Consequences

- Git is the only deployment tool.
  Editors and tools see real paths; leaving the approach means deleting one alias.
- `$HOME` is a working tree.
  The installer must set `status.showUntrackedFiles=no`, and `dotfiles add -A` can stage credentials.
- Every tracked file lands in `$HOME`.
  Repository-only files belong under `.config/dotfiles/` or `.github/`;
  top-level files and tool configs that search parent directories would apply to every project under `$HOME`.
- Host differences rely on each format's own includes and conditionals.
  Formats without them are harder to vary per machine.
- Tools started by Git hooks search for `.git`; the hook installer must export `GIT_DIR` and `GIT_WORK_TREE`.
- Revisit when many machines need different contents in files without includes,
  or when the repository must hold secrets;
  [Is this approach right for you?](@/docs/concepts/compare-approaches.md#choose-something-else-when) lists the
  alternatives.

## Details

- [The bare repository](@/docs/concepts/bare-repo.md)
- [Is this approach right for you?](@/docs/concepts/compare-approaches.md)
