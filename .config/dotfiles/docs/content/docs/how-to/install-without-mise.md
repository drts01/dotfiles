+++
title = "Install without mise"
description = "Deploy the dotfiles without downloading mise, or with Git alone and no curl or wget."
weight = 30

[extra]
type = "how-to"
+++

Deploy the dotfiles without mise; Git and a POSIX `sh` are enough to use them.

Without mise, the installer skips mise-managed tools.
It installs the pre-commit hook only when `prek` is already on `PATH`.

## Skip the mise download

Prerequisites: Git, a POSIX `sh`, and curl.

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SKIP_MISE_INSTALL=1 sh
```

## Install with Git only

Prerequisites: Git and a POSIX `sh`; no curl or wget.

1. Clone the bare repository:

   ```bash
   git clone --bare --single-branch --depth=1 https://github.com/drts01/dotfiles ~/.local/share/dotfiles
   ```

2. Run the deploy script from the clone:

   ```bash
   sh -c "$(git --git-dir="$HOME/.local/share/dotfiles" show HEAD:.config/dotfiles/mise-tasks/bootstrap.sh)"
   ```

The deploy script backs up conflicting files to `~/.df-bak`, as the one-line installer does.

## Verify

```bash
sh ~/.config/dotfiles/mise-tasks/doctor.sh
```

The doctor reports `WARN` for mise; without `prek`, it also reports `WARN` for `prek` and the pre-commit hook.
These components are optional; every other check passes.

## Add mise later

Rerun the one-line installer without `DOTFILES_SKIP_MISE_INSTALL`; it installs mise when curl or wget is available.

## Related

- [Install on a new machine](@/docs/start/install.md)
- [Update the dotfiles](@/docs/how-to/update.md)
