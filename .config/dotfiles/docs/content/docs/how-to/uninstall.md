+++
title = "Uninstall and restore backups"
description = "Remove the dotfiles and the bare repository, then restore the files the installer backed up."
weight = 80

[extra]
type = "how-to"
+++

Return your home directory to its state before the install.

{% <devlab.callout type="warning"> %}
These steps delete every tracked file in `$HOME`, including `~/.profile`, `~/.bashrc`, and `~/.ssh/config`.
Restoring `~/.df-bak` brings back only the files that the installer replaced.
{% </devlab.callout> %}

## Prerequisites

- Git and a POSIX `sh`.
- Changes you want to keep are committed and pushed, or copied elsewhere.
  Check with `cd ~ && dotfiles status`.

## Steps

1. Review the files and plugin directories that the next step deletes:

   ```bash
   cd ~ && git --git-dir="$HOME/.local/share/dotfiles" --work-tree="$HOME" ls-files
   ```

2. Delete them:

   ```bash
   cd ~ && git --git-dir="$HOME/.local/share/dotfiles" --work-tree="$HOME" ls-files -z | xargs -0 rm -rf --
   ```

3. Delete the bare repository; its Git hooks and `info/exclude` link go with it.
   `command` bypasses the `rm` alias that the dotfiles define:

   ```bash
   command rm -rf ~/.local/share/dotfiles
   ```

4. Restore the backups, then delete the backup directory:

   ```bash
   cp -Rp ~/.df-bak/. ~/ && command rm -rf ~/.df-bak
   ```

   Skip this step if `~/.df-bak` does not exist; the installer replaced no files.
   A path backed up twice holds only the later copy.

5. Optional: delete the generated shell caches:

   ```bash
   command rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/shell"
   ```

6. Optional: remove mise and all its data, if the installer added it and you do not use it elsewhere:

   ```bash
   mise implode
   ```

Empty directories from the tracked layout, such as `~/.config/sh`, can remain; delete them by hand.

## Verify

This command reports that the directory does not exist:

```bash
ls ~/.local/share/dotfiles
```

Start a new login shell; it loads your restored or system default configuration:

```bash
exec "$SHELL" -l
```

## Related

- [Install on a new machine](@/docs/start/install.md)
- [File layout](@/docs/reference/file-layout.md)
