+++
title = "Use the legacy Neovim configuration"
description = "Install and refresh the legacy Neovim plugins; Helix is the primary editor."
weight = 70

[extra]
type = "how-to"
+++

Neovim is a legacy configuration; use Helix, the primary editor, for new work;
see [Set up Helix](@/docs/how-to/helix.md).
Follow these steps to keep the Neovim plugins working for existing workflows.

## Prerequisites

- `nvim` on `PATH`.

The installer initializes the Neovim plugin submodules when `nvim` is on `PATH`.
To skip them, see [Choose plugin groups](@/docs/how-to/choose-plugin-groups.md).

## Refresh plugins

After you pull changes that add or move a plugin, initialize the plugins again:

```bash
DOTFILES_SUBMODULES=nvim sh ~/.config/dotfiles/mise-tasks/bootstrap.sh
```

## Verify

Neovim starts, loads its configuration, and exits without errors:

```bash
nvim --headless +qa
```

## Related

- [Neovim settings](@/docs/reference/nvim.md)
