+++
title = "Update the dotfiles"
description = "Fast-forward the installed dotfiles and update the mise toolchain."
weight = 40

[extra]
type = "how-to"
+++

Bring the installed dotfiles up to date with the default branch.
Updates fast-forward only and never create merge commits in `$HOME`.

## Prerequisites

- An installed bare repository at `~/.local/share/dotfiles`.
- No uncommitted changes to tracked files that conflict with incoming changes; check with `dotfiles status`.

## Update the dotfiles

Run the installed deploy script:

```bash
sh ~/.config/dotfiles/mise-tasks/bootstrap.sh
```

With mise, run the same script as a task:

```bash
mise run --cd ~/.config/dotfiles update
```

Check [Changelog](@/docs/reference/changelog.md) for updates that need a one-time migration.

## Update the toolchain

With mise, update the machine tools separately:

```bash
mise --cd ~/.config/mise bootstrap
```

## Verify

```bash
sh ~/.config/dotfiles/mise-tasks/doctor.sh
```

## Troubleshoot

If Git reports that it cannot fast-forward,
see [Update does not fast-forward](@/docs/how-to/troubleshooting.md#update-does-not-fast-forward).

## Related

- [Review the installer and pin a commit](@/docs/how-to/pin-a-commit.md)
- [Tasks](@/docs/reference/tasks.md)
