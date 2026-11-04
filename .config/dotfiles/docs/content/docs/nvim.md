+++
title = "Neovim (legacy)"
description = "Maintain the legacy Neovim configuration; Helix is the primary editor."
weight = 2
+++

Neovim is a legacy configuration; use Helix, the primary editor, for new work.
The Neovim configuration remains available for existing workflows.

## Install plugins

Prerequisite: `nvim` on `PATH`.

Bootstrap initializes the Neovim plugin submodules when `nvim` is on `PATH`.
Skip them with `DOTFILES_SKIP_SUBMODULES=nvim`.

After you pull changes that add or move a plugin, initialize the plugins again:

```bash
DOTFILES_SUBMODULES=nvim sh ~/.config/dotfiles/mise-tasks/bootstrap.sh
```

Verify that Neovim starts and loads its configuration without errors:

```bash
nvim --headless +qa
```

## Configuration

Configuration lives in `.config/nvim/init.lua`.
Plugins load through Neovim's native package system, without a plugin manager, and are tracked as Git submodules:

- `.config/nvim/pack/plugins/start/`: loaded on startup.
- `.config/nvim/pack/plugins/opt/`: loaded on demand with `:packadd`.

Defaults:

- Leader key: `,`.
- Backup, swap, and undo files under `stdpath('config')` (`backup/`, `swap/`, `undo/`), outside project directories.
- `termguicolors`, `signcolumn=yes`, and visible whitespace (`list`, `listchars`).
- Literal tabs (`expandtab=false`) with 4-column indentation.
