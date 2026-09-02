# Dotfiles

Manage system environment configurations via a Git bare repository.

## Installation

Run the bootstrap script to deploy configuration files onto a fresh machine:

```bash
curl -sL https://githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

## Usage

Interact with the repository using the system alias:

```bash
dotfiles status
dotfiles add .config/nvim/init.lua
dotfiles commit -m "feat(nvim): update config"
dotfiles push
```
