+++
title = "drts01/dotfiles"
description = "Personal dotfiles managed via a Git bare repository; mise is optional."

[extra]
home_layout = "wide"
home_eyebrow = "Dotfiles documentation"
home_primary_action_label = "Read the docs"
home_primary_action_path = "/docs/"
home_features = [
  { kicker = "Start", title = "Bootstrap", description = "Deploy configuration files onto a fresh machine." },
  { kicker = "Configure", title = "Helix & shells", description = "Configure editing and shared sh, Bash, and Zsh environments." },
  { kicker = "Automate", title = "Git hooks (prek)", description = "Fast, Rust-based pre-commit hook management." },
]
+++

Manage system environment configurations via a Git bare repository.
Use Git and a POSIX shell; mise is optional.

This repo tracks dotfiles (`.config/`, `.zshenv`, etc.) directly against `$HOME` using a bare git repository at
`~/.local/share/dotfiles`, rather than symlinking from a separate clone.
See [Bootstrap](/docs/bootstrap/) for how a fresh machine is set up.

## Layout

| Path                                     | Purpose                                                                                |
| ---------------------------------------- | -------------------------------------------------------------------------------------- |
| `.config/dotfiles/`                      | Bootstrap script, `mise` tasks, and this documentation                                 |
| `.config/helix/`                         | Helix editor configuration (primary editor)                                            |
| `.config/nvim/`                          | Legacy Neovim configuration — see [Neovim](/docs/nvim/)                                |
| `.config/sh/`, `.config/zsh/`, `.bashrc` | Shared shell and shell-specific configuration — see [Shell environments](/docs/shell/) |
| `.config/dotfiles/prek.toml`             | Git hooks configuration — see [Git hooks](/docs/prek/)                                 |

## Interact with the repo

```bash
dotfiles status
dotfiles add .config/helix/config.toml
dotfiles commit -m "feat(helix): update config"
dotfiles push
```

`dotfiles` is a shell alias (`.config/sh/sh.d/20_aliases.sh`) equivalent to
`git --git-dir=$HOME/.local/share/dotfiles --work-tree=$HOME`.
