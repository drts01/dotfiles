+++
title = "Neovim settings"
description = "Files, plugin directories, and defaults of the legacy Neovim configuration."
weight = 70

[extra]
type = "reference"
+++

Settings of the legacy Neovim configuration in `.config/nvim/`.
Plugins load through Neovim's native package system, without a plugin manager.

## Files

| Path                                | Contents                                     |
| ----------------------------------- | -------------------------------------------- |
| `.config/nvim/init.lua`             | Configuration                                |
| `.config/nvim/pack/plugins/start/`  | Plugin submodules loaded on startup          |
| `.config/nvim/pack/plugins/opt/`    | Plugins loaded on demand with `:packadd`     |

## Defaults

| Setting                       | Value                                                          |
| ----------------------------- | -------------------------------------------------------------- |
| Leader key                    | `,`                                                            |
| Backup, swap, and undo files  | `backup/`, `swap/`, `undo/` under `stdpath('config')`          |
| Colors and sign column        | `termguicolors`, `signcolumn=yes`                              |
| Whitespace                    | Visible: `list`, `listchars`                                   |
| Indentation                   | Literal tabs (`expandtab=false`), 4 columns                    |
