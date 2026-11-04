+++
title = "Install and run Git hooks"
description = "Install the prek pre-commit hook for the bare repository and run every hook on demand."
weight = 60

[extra]
type = "how-to"
+++

Check formatting, linting, and spelling on every commit to the dotfiles.

## Prerequisites

- [`prek`](https://github.com/j178/prek) on `PATH`, or mise to install the locked version.

The installer installs the hook automatically when either is available.

## Install the hook

With mise:

```bash
mise run --cd ~/.config/dotfiles install:git-hooks
```

Without mise:

```bash
cd ~/.config/dotfiles && sh mise-tasks/install-hooks.sh
```

Rerun either command to repair a hook.

## Run every hook

Set `GIT_DIR` and `GIT_WORK_TREE`; `prek` cannot find the bare repository from `$HOME` on its own:

```bash
cd ~ && GIT_DIR="$HOME/.local/share/dotfiles" GIT_WORK_TREE="$HOME" \
  prek run --config .config/dotfiles/prek.toml --all-files
```

Fixers such as `typos`, `end-of-file-fixer`, and `ryl` rewrite files in place; review `dotfiles diff` afterwards.

## Verify

```bash
sh ~/.config/dotfiles/mise-tasks/doctor.sh
```

The `Bare-repo hook configuration` check passes.
It fails when the hook lacks the bare-repository overrides; reinstall the hook to fix it.

## Related

- [Hooks](@/docs/reference/hooks.md)
- [Why hooks need `GIT_DIR`](@/docs/concepts/bare-repo.md#hooks-and-git-dir)
