---
icon: lucide/home
---

# Overview

Manage system environment configurations via a Git bare repository.

This repo tracks dotfiles (`.config/`, `.zshenv`, etc.) directly against
`$HOME` using a bare git repository at `~/.local/share/dotfiles`, rather than
symlinking from a separate clone. See [Bootstrap](bootstrap.md) for how a
fresh machine is set up.

## Layout

| Path | Purpose |
| --- | --- |
| `.config/dotfiles/` | Bootstrap script, `mise` tasks, and this documentation |
| `.config/nvim/` | Neovim configuration — see [Neovim](nvim.md) |
| `.config/zsh/` | Zsh configuration — see [Zsh](zsh.md) |
| `.config/dotfiles/prek.toml` | Git hooks configuration — see [Git hooks](prek.md) |

## Interact with the repo

```bash
dotfiles status
dotfiles add .config/nvim/init.lua
dotfiles commit -m "feat(nvim): update config"
dotfiles push
```

`dotfiles` is a shell alias (`.config/zsh/zsh.d/20_aliases.zshrc`) equivalent
to `git --git-dir=$HOME/.local/share/dotfiles --work-tree=$HOME`.
