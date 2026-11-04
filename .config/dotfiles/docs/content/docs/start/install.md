+++
title = "Install on a new machine"
description = "Deploy the dotfiles into your home directory with Git and a POSIX shell, then confirm that they load."
weight = 10

[extra]
type = "tutorial"
+++

Deploy the dotfiles into your home directory with one command, then confirm that your shell loads them.

## Before you begin

You need:

- Git and a POSIX `sh`.
- curl, to fetch the one-line installer.
  Without curl, [install with Git only](@/docs/how-to/install-without-mise.md#install-with-git-only).
- Network access to `github.com`.

mise is optional.
When curl or wget is available, the installer uses it to fetch mise; the dotfiles work without it.

The installer changes your home directory:

- Moves existing files that conflict with tracked files to `~/.df-bak`, created with mode `700`.
  A later backup of the same path overwrites the earlier one.
- Installs mise to `~/.local/bin/mise` if it is missing.
  To skip it, [install without mise](@/docs/how-to/install-without-mise.md).
- Installs a pre-commit hook in the bare repository when mise or `prek` is available.

To read the installer before it runs,
[review the installer and pin a commit](@/docs/how-to/pin-a-commit.md) instead of the next step.

## Run the installer

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

Checkpoint: the last line reads `Dotfiles bootstrap complete.`

- Lines that start with `Warning:` report optional components; continue.
- A line that starts with `ERROR:` stops the install; see [Troubleshooting](@/docs/how-to/troubleshooting.md).

## Check the install

```bash
sh ~/.config/dotfiles/mise-tasks/doctor.sh
```

Checkpoint: the last line reads `All installation checks passed.` or `Installation checks passed with warnings.`

- `WARN` lines for mise, `prek`, and the pre-commit hook report optional components.
- Fix every `FAIL` line before you continue;
  [Troubleshooting](@/docs/how-to/troubleshooting.md#doctor-output) lists each fix.

## Load the configuration

Start a new login shell:

```bash
exec "$SHELL" -l
```

Checkpoint: this command prints the alias definition:

```bash
alias dotfiles
```

## Inspect the repository

The `dotfiles` alias runs Git against the installed repository from any directory under `$HOME`:

```bash
cd ~ && dotfiles status
```

Checkpoint: Git reports `nothing to commit`.

If the installer printed `Backing up pre-existing dotfiles`,
compare your previous files in `~/.df-bak` with the tracked versions, and copy back any settings you want to keep.

## What you built

- A bare Git repository at `~/.local/share/dotfiles` that tracks files directly in `$HOME`;
  see [The bare repository](@/docs/concepts/bare-repo.md).
- The `dotfiles` alias, Git for that repository.
- Shared configuration for POSIX `sh`, Bash, and Zsh.
- Optional: mise in `~/.local/bin` and a pre-commit hook.

## Next steps

- [Customize the shell](@/docs/how-to/customize-shell.md).
- [Update the dotfiles](@/docs/how-to/update.md).
- [Choose plugin groups](@/docs/how-to/choose-plugin-groups.md).
- [Uninstall and restore backups](@/docs/how-to/uninstall.md).
