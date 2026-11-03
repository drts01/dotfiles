+++
title = "Neovim (legacy)"
updated = 2026-11-01
weight = 2
+++

Helix is the primary editor.
Neovim remains available as a legacy configuration.
Bootstrap installs or updates its plugin submodules when `nvim` is on `PATH`,
unless you exclude them with `DOTFILES_SKIP_SUBMODULES=nvim`.

Configuration lives in `.config/nvim/init.lua`, using Neovim's native package manager — no plugin manager
(no vim-plug/lazy.nvim).
Plugins are tracked as git submodules:

- `.config/nvim/pack/plugins/start/` — auto-loaded on startup
- `.config/nvim/pack/plugins/opt/` — loaded manually with `:packadd`

## Highlights

- Leader key: `,`
- Vim-style undo/backup/swap files under `stdpath('config')` (`backup/`,
  `swap/`, `undo/`), so they don't pollute project directories.
- `termguicolors`, `signcolumn=yes`, whitespace visualization
  (`list`/`listchars`) enabled by default.
- Literal tabs (`expandtab=false`), 4-width indentation.

After pulling changes that add or move a plugin,
rerun `DOTFILES_SUBMODULES=nvim sh ~/.config/dotfiles/mise-tasks/bootstrap.sh`.
The default update initializes Neovim plugins only when `nvim` is on `PATH` and they are not excluded.
