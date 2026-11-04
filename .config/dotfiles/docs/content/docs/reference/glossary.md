+++
title = "Glossary"
description = "Terms used across the dotfiles documentation."
weight = 80

[extra]
type = "reference"
+++

Terms used across this documentation, in alphabetical order.

| Term              | Meaning                                                                                                                                             |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Backup directory  | `~/.df-bak`, mode `700`; holds files that the first checkout replaced. See [Uninstall](@/docs/how-to/uninstall.md).                                 |
| Bare repository   | The Git repository at `~/.local/share/dotfiles`; it holds history and no working tree of its own.                                                   |
| Deploy script     | `~/.config/dotfiles/mise-tasks/bootstrap.sh`; checks out or updates `$HOME`. Runs as the `bootstrap` and `update` tasks.                            |
| Development clone | A regular `git clone` used to change and test the repository; never the installed copy.                                                             |
| Doctor            | `~/.config/dotfiles/mise-tasks/doctor.sh`; checks the install and prints `OK`, `WARN`, or `FAIL` per check.                                         |
| `dotfiles` alias  | Git with `--git-dir` set to the bare repository and `--work-tree` set to `$HOME`.                                                                   |
| Entrypoint        | `.config/dotfiles/bootstrap.sh`, fetched by the one-line installer; resolves a commit, then runs the deploy script.                                 |
| Gitlink           | The commit ID that a repository records for a submodule; it fixes the submodule version.                                                            |
| Machine toolchain | Tools declared in `~/.config/mise/`, installed with mise; separate from the dotfiles and optional.                                                  |
| mise              | Optional tool version manager; installs the machine toolchain and runs tasks.                                                                       |
| Pin               | A full commit ID in `DOTFILES_REF`; the installer deploys that commit or fails. See [Pin a commit](@/docs/how-to/pin-a-commit.md).                  |
| Plugin group      | A set of submodules selected together: `zsh`, `nvim`, `lua`, or `docs`. See [Environment variables](@/docs/reference/environment.md#plugin-groups). |
| prek              | The Git hook runner; reads `~/.config/dotfiles/prek.toml`. See [Hooks](@/docs/reference/hooks.md).                                                  |
| Work tree         | The directory whose files Git tracks; for the dotfiles, `$HOME`.                                                                                    |
