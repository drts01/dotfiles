+++
title = "Environment variables"
description = "Variables that control the installer, the deploy script, and plugin groups."
weight = 10

[extra]
type = "reference"
+++

Variables read by the entrypoint, `bootstrap.sh`, and the deploy script, `mise-tasks/bootstrap.sh`.
Each applies to one run.

## Installer

| Variable                     | Default                              | Read by     | Purpose                                                  |
| ---------------------------- | ------------------------------------ | ----------- | -------------------------------------------------------- |
| `DOTFILES_REF`               | default branch                       | Entrypoint  | Branch, tag, or full commit ID to install                |
| `DOTFILES_SKIP_MISE_INSTALL` | unset                                | Entrypoint  | Any value skips installing mise                          |
| `MISE_INSTALL_PATH`          | `~/.local/bin/mise`                  | Entrypoint  | mise binary location, added to `PATH`                    |
| `REPO_URL`                   | `https://github.com/drts01/dotfiles` | Both        | Repository to fetch and clone                            |
| `DEST_DIR`                   | `~/.local/share/dotfiles`            | Both        | Bare repository location; also read by the doctor        |
| `DOTFILES_SUBMODULES`        | `auto`                               | Deploy      | Plugin groups to initialize; see below                   |
| `DOTFILES_SKIP_SUBMODULES`   | unset                                | Deploy      | `all`, or a comma-separated list of groups to exclude    |
| `DOTFILES_COMMIT`            | set by the entrypoint                | Deploy      | Full commit ID to deploy and verify                      |
| `DOTFILES_BRANCH`            | remote default branch                | Deploy      | Branch that a pinned fresh install tracks                |

The entrypoint passes `REPO_URL`, `DEST_DIR`, and the plugin-group variables through to the deploy script.

## Plugin groups

`DOTFILES_SUBMODULES` accepts `auto`, `all`, `none`, or a comma-separated list of groups.

| Group  | Required tool     | Path                              | Contents                       | Selected by       |
| ------ | ----------------- | --------------------------------- | ------------------------------ | ----------------- |
| `zsh`  | `zsh`             | `.local/share/zsh`                | Zsh plugins and prompt         | `auto`, `all`     |
| `nvim` | `nvim`            | `.config/nvim/pack/plugins/start` | Legacy Neovim plugins          | `auto`, `all`     |
| `lua`  | `lua` or `luajit` | `.local/share/z.lua`              | `z.lua`                        | `auto`, `all`     |
| `docs` | `zola`            | `.config/dotfiles/docs/themes`    | Documentation site theme       | `all`, explicitly |

- Every group requires its tool, even when selected explicitly.
- Unknown group names fail before checkout.
- Helix needs no submodules.
