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

Each path links to its source in the repository.
This site explains behavior that needs it; the linked files hold the complete settings.

### Shell

| Path                                                                                                                              | Tool               | Contents                                                                             |
| --------------------------------------------------------------------------------------------------------------------------------- | ------------------ | ------------------------------------------------------------------------------------ |
| {{<source path=".profile" />}}, {{<source path=".bashrc" />}}, {{<source path=".bash_profile" />}}, {{<source path=".zshenv" />}} | sh, Bash, Zsh      | Entry points; see [Shell files](@/docs/reference/shell.md)                           |
| {{<source path=".config/sh/" />}}                                                                                                 | POSIX sh           | Modules shared by every shell                                                        |
| {{<source path=".config/zsh/" />}}                                                                                                | Zsh                | Zsh-only modules                                                                     |
| {{<source path=".config/spaceship.zsh" />}}                                                                                       | Spaceship          | Zsh prompt settings                                                                  |
| {{<source path=".config/atuin/" />}}                                                                                              | Atuin              | Shell history search and theme                                                       |
| {{<source path=".local/share/zsh/" />}}, {{<source path=".local/share/z.lua/" />}}                                                | Zsh plugins, z.lua | Plugin submodules; see [Choose plugin groups](@/docs/how-to/choose-plugin-groups.md) |

### Editors

| Path                                         | Tool         | Contents                                                       |
| -------------------------------------------- | ------------ | -------------------------------------------------------------- |
| {{<source path=".config/helix/" />}}         | Helix        | Primary editor; see [Set up Helix](@/docs/how-to/helix.md)     |
| {{<source path=".config/nvim/" />}}          | Neovim       | Legacy editor; see [Neovim settings](@/docs/reference/nvim.md) |
| {{<source path=".config/vim/" />}}           | Vim          | Fallback editor                                                |
| {{<source path=".config/zed/" />}}           | Zed          | Settings and agent rules                                       |
| {{<source path="Documents/Cline/Rules/" />}} | Cline        | Global agent rules                                             |
| {{<source path=".editorconfig" />}}          | EditorConfig | Indentation and line endings for every editor                  |

### Terminals

| Path                                     | Tool      | Contents                       |
| ---------------------------------------- | --------- | ------------------------------ |
| {{<source path=".config/alacritty/" />}} | Alacritty | Terminal emulator and theme    |
| {{<source path=".config/rio/" />}}       | Rio       | Terminal emulator and theme    |
| {{<source path=".config/zellij/" />}}    | Zellij    | Terminal multiplexer and theme |

### Command-line tools

| Path                                    | Tool    | Contents                                                 |
| --------------------------------------- | ------- | -------------------------------------------------------- |
| {{<source path=".config/bat/" />}}      | bat     | Theme, style, and paging                                 |
| {{<source path=".config/fd/" />}}       | fd      | Default search flags                                     |
| {{<source path=".config/ripgreprc" />}} | ripgrep | Default search flags; read through `RIPGREP_CONFIG_PATH` |
| {{<source path=".config/.curlrc" />}}   | curl    | Default request flags                                    |
| {{<source path=".config/aria2/" />}}    | aria2   | Download defaults                                        |

### Toolchains and dependencies

| Path                                    | Tool     | Contents                                                  |
| --------------------------------------- | -------- | --------------------------------------------------------- |
| {{<source path=".config/mise/" />}}     | mise     | Machine toolchain, split into tool groups under `conf.d/` |
| {{<source path=".config/uv/" />}}       | uv       | Python package resolution                                 |
| {{<source path=".config/prek/" />}}     | prek     | Hook update policy                                        |
| {{<source path=".config/renovate/" />}} | Renovate | Local CLI configuration                                   |

### Linters and formatters

| Path                                   | Tool    | Contents                          |
| -------------------------------------- | ------- | --------------------------------- |
| {{<source path=".config/vale/" />}}    | Vale    | Prose rules and the `House` style |
| {{<source path=".config/rumdl/" />}}   | rumdl   | Markdown lint rules               |
| {{<source path=".config/ryl/" />}}     | ryl     | YAML lint rules                   |
| {{<source path=".config/yamlfmt/" />}} | yamlfmt | YAML formatting                   |
| {{<source path=".config/tombi/" />}}   | Tombi   | TOML formatting                   |

### Git and SSH

| Path                                                                    | Tool    | Contents                                           |
| ----------------------------------------------------------------------- | ------- | -------------------------------------------------- |
| {{<source path=".config/git/" />}}                                      | Git     | Global configuration, attributes, and ignore rules |
| {{<source path=".ssh/config" />}}, {{<source path=".ssh/config.d/" />}} | OpenSSH | Client defaults and per-host settings              |

### Repository

| Path                                    | Tool     | Contents                                        |
| --------------------------------------- | -------- | ----------------------------------------------- |
| {{<source path=".config/dotfiles/" />}} | dotfiles | Installer, tasks, tests, and this documentation |
| {{<source path=".github/" />}}          | GitHub   | README, contributing guide, and CI              |
| {{<source path=".gitmodules" />}}       | Git      | Submodule definitions                           |

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
