+++
title = "The bare repository"
description = "Why Git tracks the dotfiles in place in $HOME, and what that means for status, ignores, and hooks."
weight = 10

[extra]
type = "explanation"
+++

Git tracks the dotfiles in place: the files in `$HOME` are the working tree, with no symlinks and no separate clone.

## Context

Most dotfile setups keep a clone in a project directory and link each file into `$HOME`.
The links need a manager, break when a tool replaces a file with a regular one, and hide the real path from editors.

## Design

- A bare repository at `~/.local/share/dotfiles` holds the history; it has no working tree of its own.
- Every command passes the working tree explicitly: `--work-tree="$HOME"`.
  The repository keeps `core.bare=true` and never stores `core.worktree`, a combination that makes Git warn.
- The `dotfiles` alias wraps those options:

  ```bash
  git --git-dir=$HOME/.local/share/dotfiles --work-tree=$HOME -c diff.relative=false
  ```

  `diff.relative=false` overrides a global setting, so diffs show paths from `$HOME` in every directory.
- Plain `git` in `$HOME` finds no repository.
  Other repositories under `$HOME` and tools that search upward for `.git` are unaffected.

Every tracked file lands in `$HOME`.
Repository-only files therefore live under `~/.config/dotfiles/` and `~/.github/`.

## Untracked files

`$HOME` holds thousands of files that the repository never tracks.
The installer sets `status.showUntrackedFiles=no`, so `dotfiles status` lists only tracked files;
the doctor fails without it.

The tradeoff: new files stay invisible until you add them by name.
`dotfiles add -A` or `dotfiles add .` stages every file below the current directory, including credentials.

## Ignore rules

The installer links the repository's `info/exclude` to the tracked `~/.config/dotfiles/gitignore`.
Git reads `info/exclude` only for its own repository, so these rules never affect other repositories under `$HOME`.
Changes to the tracked list take effect after the next update without relinking.

## Hooks and `GIT_DIR`

Git runs hooks with the repository's settings, but tools started by a hook search for a `.git` directory,
and `$HOME` has none.
The hook installer therefore patches the generated pre-commit hook to export `GIT_DIR` and `GIT_WORK_TREE`.

The hooks run through [`prek`](https://github.com/j178/prek).
It reads the same hook definitions as Python `pre-commit`, here in TOML, and ships as a single binary,
so mise pins it without a Python runtime.

## Related

- [Install and run Git hooks](@/docs/how-to/git-hooks.md)
- [How the installer works](@/docs/concepts/bootstrap-flow.md)
- [File layout](@/docs/reference/file-layout.md)

Decisions: [ADR-0001](@/docs/contributing/decisions/0001-bare-repository.md).
