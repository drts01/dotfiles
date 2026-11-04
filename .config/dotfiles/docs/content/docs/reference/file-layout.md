+++
title = "File layout"
description = "Where the tracked files land in $HOME, and where the installer writes."
weight = 60

[extra]
type = "reference"
+++

Paths relative to `$HOME`.
Every tracked file lands at its repository path.

## Tracked configuration

| Path                                              | Contents                                                         |
| ------------------------------------------------- | ---------------------------------------------------------------- |
| `.profile`, `.bashrc`, `.bash_profile`, `.zshenv` | Shell entry points; see [Shell files](@/docs/reference/shell.md) |
| `.config/sh/`, `.config/zsh/`                     | Shared and Zsh-specific shell modules                            |
| `.config/helix/`                                  | Helix, the primary editor                                        |
| `.config/nvim/`                                   | Legacy Neovim; see [Neovim settings](@/docs/reference/nvim.md)   |
| `.config/mise/`                                   | Machine toolchain for mise                                       |
| `.config/git/`                                    | Global Git configuration, attributes, and ignore rules           |
| `.config/<tool>/`                                 | Other tool configurations                                        |
| `.ssh/config`, `.ssh/config.d/`                   | SSH client configuration                                         |
| `.local/share/zsh/`, `.local/share/z.lua/`        | Plugin submodules                                                |
| `.config/dotfiles/`                               | Installer, tasks, tests, and this documentation                  |
| `.github/`                                        | Repository README, contributing guide, and CI                    |
| `.editorconfig`, `.gitmodules`                    | Editor settings and submodule definitions                        |
| `Documents/Cline/Rules/`                          | Cline global rules                                               |

## Installer state

| Path                                        | Contents                                                     |
| ------------------------------------------- | ------------------------------------------------------------ |
| `.local/share/dotfiles/`                    | Bare repository, including hooks and `info/exclude`          |
| `.local/share/dotfiles/hooks/pre-commit`    | `prek` hook, patched for the bare repository                 |
| `.local/share/dotfiles/info/exclude`        | Symlink to `.config/dotfiles/gitignore`                      |
| `.df-bak/`                                  | Files replaced at first checkout; mode `700`                 |
| `.local/bin/mise`                           | mise, when the installer added it                            |
| `.cache/shell/`                             | Cached shell initialization code                             |
| `.local/state/.*_history`                   | Per-shell history files                                      |

## Tooling directory

| Path in `.config/dotfiles/` | Contents                                                                |
| --------------------------- | ----------------------------------------------------------------------- |
| `bootstrap.sh`              | One-line installer entrypoint                                           |
| `mise-tasks/`               | Deploy script, doctor, hook installer, ignore link                      |
| `mise.toml`, `mise.lock`    | Installed tasks and deployment lock (prek only)                         |
| `dev-mise.lock`             | Development lock; linked as `mise.local.lock` in a clone                |
| `prek.toml`                 | Hook configuration                                                      |
| `gitignore`                 | Ignore rules linked into `info/exclude`                                 |
| `docs/`                     | Source of this site                                                     |
