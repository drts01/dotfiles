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
| `REPO_URL`                   | `https://github.com/drts01/dotfiles` | Both        | Repository to fetch; `https://`, `ssh://`, or local path |
| `DEST_DIR`                   | `~/.local/share/dotfiles`            | Both        | Bare repository location; also read by the doctor        |
| `DOTFILES_SUBMODULES`        | `auto`                               | Deploy      | Plugin groups to initialize; see below                   |
| `DOTFILES_SKIP_SUBMODULES`   | unset                                | Deploy      | `all`, or a comma-separated list of groups to exclude    |
| `DOTFILES_COMMIT`            | set by the entrypoint                | Deploy      | Full commit ID to deploy and verify                      |
| `DOTFILES_BRANCH`            | remote default branch                | Both        | Branch that a commit or tag pin tracks                   |

The entrypoint passes `REPO_URL`, `DEST_DIR`, `DOTFILES_BRANCH`, and the plugin-group variables to the deploy script.
Both scripts reject `http://`, `git://`, and `ftp://` URLs; those transports do not authenticate the server.

## Plugin groups

`DOTFILES_SUBMODULES` accepts `auto`, `all`, `none`, or a comma-separated list of groups.

| Group  | Required tool     | Path                              | Contents                       | Selected by       |
| ------ | ----------------- | --------------------------------- | ------------------------------ | ----------------- |
| `zsh`  | `zsh`             | `.local/share/zsh`                | Zsh plugins and prompt         | `auto`, `all`     |
| `nvim` | `nvim`            | `.config/nvim/pack/plugins/start` | Legacy Neovim plugins          | `auto`, `all`     |
| `vim`  | `vim`             | `.config/vim/pack/plugins`        | Vim packages in `start/` and `opt/` | `auto`, `all` |
| `lua`  | `lua` or `luajit` | `.local/share/z.lua`              | `z.lua`                        | `auto`, `all`     |
| `docs` | `zola`            | `.config/dotfiles/docs/themes`    | Documentation site theme       | `all`, explicitly |

- Every group requires its tool, even when selected explicitly.
- Unknown group names fail before checkout.
- Helix needs no submodules.

## Vim startup

These variables control Vim startup and recovery storage, not installer group selection.
The shell defines `vim()` only when the Vim executable and XDG `vimrc` exist.
Its `VIMINIT` assignment is process-local, not a global export, so `nvim` is unaffected.
`command vim` bypasses the wrapper and uses native discovery;
scripts launching older Vim outside the configured shell need an explicit `-u` path.

| Variable | Default | Purpose |
| -------- | ------- | ------- |
| `VIMINIT` | Preserved if set, including empty | Otherwise the `vim()` wrapper supplies a process-local expression to source the XDG `vimrc`, escaping its path with `fnameescape()`; supports older Vim without native XDG discovery |
| `XDG_CONFIG_HOME` | `~/.config` | Locates `vim/vimrc` for the shell's `vim()` wrapper guard |
| `XDG_STATE_HOME` | `~/.local/state` | Stores private Vim recovery directories under `vim/`, created with mode `0700` |

See [Vim settings](@/docs/reference/vim.md) for packages, mappings, and tool requirements.
