+++
title = "drts01/dotfiles"
description = "Personal dotfiles managed via a Git bare repository; mise is optional."

[extra]
home_layout = "wide"
home_eyebrow = "Dotfiles documentation"
home_primary_action_label = "Read the docs"
home_primary_action_path = "/docs/"
home_features = [
  { kicker = "Start", title = "Bootstrap", description = "Install, update, and verify the dotfiles with Git and a POSIX shell." },
  { kicker = "Configure", title = "Helix & shells", description = "Configure editing and shared sh, Bash, and Zsh environments." },
  { kicker = "Automate", title = "Git hooks (prek)", description = "Format, lint, and spell-check every commit." },
]
+++

Manage system environment configurations via a Git bare repository.
Use Git and a POSIX shell; mise is optional.

This repository tracks dotfiles, such as `.config/` and `.zshenv`,
directly in `$HOME` through a bare Git repository at `~/.local/share/dotfiles`,
instead of symlinking them from a separate clone.
See [Bootstrap](@/docs/bootstrap.md) to install them on a new machine.

## Layout

| Path                                     | Purpose                                                                                   |
| ---------------------------------------- | ----------------------------------------------------------------------------------------- |
| `.config/dotfiles/`                      | Bootstrap script, `mise` tasks, and this documentation                                    |
| `.config/helix/`                         | Helix editor configuration (primary editor)                                               |
| `.config/nvim/`                          | Legacy Neovim configuration — see [Neovim](@/docs/nvim.md)                                |
| `.config/sh/`, `.config/zsh/`, `.bashrc` | Shared shell and shell-specific configuration — see [Shell environments](@/docs/shell.md) |
| `.config/dotfiles/prek.toml`             | Git hooks configuration — see [Git hooks](@/docs/prek.md)                                 |

## Use the repository

```bash
dotfiles status
dotfiles add .config/helix/config.toml
dotfiles commit -m "feat(helix): update config"
dotfiles push
```

`dotfiles` is a shell alias, defined in `.config/sh/sh.d/20_aliases.sh`,
for `git --git-dir=$HOME/.local/share/dotfiles --work-tree=$HOME`.
