+++
title = "drts01/dotfiles"
description = "Personal dotfiles managed via a Git bare repository, bootstrapped with mise."

[extra]
home_layout = "wide"
home_eyebrow = "Dotfiles documentation"
home_primary_action_label = "Read the docs"
home_primary_action_path = "/docs/"
home_features = [
  { kicker = "Start", title = "Bootstrap", description = "Deploy configuration files onto a fresh machine." },
  { kicker = "Configure", title = "Neovim & Zsh", description = "Per-config guides for everyday editing and shell setup." },
  { kicker = "Automate", title = "Git hooks (prek)", description = "Fast, Rust-based pre-commit hook management." },
]
+++

Manage system environment configurations via a Git bare repository.

This repo tracks dotfiles (`.config/`, `.zshenv`, etc.) directly against
`$HOME` using a bare git repository at `~/.local/share/dotfiles`, rather than
symlinking from a separate clone. See [Bootstrap](/docs/bootstrap/) for how a
fresh machine is set up.

## Layout

| Path | Purpose |
| --- | --- |
| `.config/dotfiles/` | Bootstrap script, `mise` tasks, and this documentation |
| `.config/nvim/` | Neovim configuration — see [Neovim](/docs/nvim/) |
| `.config/zsh/` | Zsh configuration — see [Zsh](/docs/zsh/) |
| `.config/dotfiles/prek.toml` | Git hooks configuration — see [Git hooks](/docs/prek/) |

## Interact with the repo

```bash
dotfiles status
dotfiles add .config/nvim/init.lua
dotfiles commit -m "feat(nvim): update config"
dotfiles push
```

`dotfiles` is a shell alias (`.config/zsh/zsh.d/20_aliases.zshrc`) equivalent
to `git --git-dir=$HOME/.local/share/dotfiles --work-tree=$HOME`.
