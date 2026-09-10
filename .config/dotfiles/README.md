# Dotfiles

Manage system environment configurations via a Git bare repository.

## Installation

Run the bootstrap script to deploy configuration files onto a fresh machine:

```bash
curl -sL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

This clones the bare repo to `~/.local/share/dotfiles`, checks out the tracked
files into `$HOME` (backing up any conflicting pre-existing files to
`~/.df-bak`), installs [mise](https://mise.jdx.dev), and runs the post-clone
setup tasks (`uv`-managed CLI tools, `prek` git hooks).

Verify the install succeeded:

```bash
mise run --cwd ~/.config/dotfiles doctor
```

## Usage

Interact with the repository using the system alias:

```bash
dotfiles status
dotfiles add .config/nvim/init.lua
dotfiles commit -m "feat(nvim): update config"
dotfiles push
```

### Updating

Pull the latest dotfiles, sync submodules, and re-run setup:

```bash
mise run --cwd ~/.config/dotfiles update
```

### Available mise tasks

| Task | Description |
| --- | --- |
| `setup` | Install `uv`-managed CLI tools and `prek` git hooks (runs automatically during bootstrap) |
| `update` | Pull latest changes, sync submodules, and re-run `setup` |
| `doctor` | Verify required tools, the bare repo, and git hooks are correctly installed |

## Documentation

Full documentation (setup, `mise` tasks, per-config guides for Neovim, Zsh,
and git hooks) is built with [Zensical](https://zensical.org) from
`.config/dotfiles/docs/`. Preview it locally:

```bash
mise run --cwd ~/.config/dotfiles docs:serve
```

Or build the static site:

```bash
mise run --cwd ~/.config/dotfiles docs:build
```

## License


Licensed under the [Apache License, Version 2.0](LICENSE).
