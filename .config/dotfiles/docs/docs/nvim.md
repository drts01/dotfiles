---
icon: lucide/pencil
---

# Neovim

Configuration lives in `.config/nvim/init.lua`, using Neovim's native package
manager — no plugin manager (no vim-plug/lazy.nvim). Plugins are tracked as
git submodules:

- `.config/nvim/pack/plugins/start/` — auto-loaded on startup
- `.config/nvim/pack/plugins/opt/` — loaded manually with `:packadd`

## Highlights

- Leader key: `,`
- Vim-style undo/backup/swap files under `stdpath('config')` (`backup/`,
  `swap/`, `undo/`), so they don't pollute project directories.
- `termguicolors`, `signcolumn=yes`, whitespace visualization
  (`list`/`listchars`) enabled by default.
- Literal tabs (`expandtab=false`), 4-width indentation.

Since plugins are submodules, `dotfiles submodule update --init` (or
`mise run update`, which does this automatically) is required after pulling
changes that add or move a plugin.
