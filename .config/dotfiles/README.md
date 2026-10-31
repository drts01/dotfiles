# Dotfiles

Manage system environment configurations via a Git bare repository.

## Features

- Manage local environment without root access
- No dependencies other than Git and Borne Shell.
- Support shells: Borne, BASH, Zsh

mise is not required to use dot files. mise is used to manage CLI tools.

## Installation

Run the bootstrap script to deploy configuration files onto a fresh machine:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

This installs [mise](https://mise.jdx.dev), clones the bare repo to `~/.local/share/dotfiles`,
checks out the tracked files into `$HOME`
(backing up any conflicting pre-existing files to `~/.df-bak`),
and runs the post-clone bootstrap tasks (mise-managed CLI tools, `prek` git hooks) when mise is available.

Skip mise and deploy with git only:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | SKIP_MISE_INSTALL=1 sh
```

Without curl or wget, use git as the installer:

```bash
git clone --bare --single-branch --depth=1 https://github.com/drts01/dotfiles ~/.local/share/dotfiles
sh -c "$(git --git-dir="$HOME/.local/share/dotfiles" show HEAD:.config/dotfiles/mise-tasks/bootstrap.sh)"
```

Verify the install succeeded:

```bash
mise run --cd ~/.config/dotfiles doctor
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

Pull the latest dotfiles, sync submodules, and re-run bootstrap:

```bash
mise run --cd ~/.config/dotfiles update
```

### Available mise tasks

| Task        | Description                                                                             |
| ----------- | --------------------------------------------------------------------------------------- |
| `bootstrap` | Install mise-managed CLI tools and `prek` git hooks (runs automatically during install) |
| `update`    | Pull latest changes, sync submodules, and re-run `bootstrap`                            |
| `doctor`    | Verify required tools, the bare repo, and git hooks are correctly installed             |

## Documentation

Full documentation (setup, `mise` tasks, per-config guides for Neovim, Zsh, and git hooks) is built with
[Zola](https://www.getzola.org) and the [devlab-theme](https://codeberg.org/RiPetitor/devlab-theme) from
`.config/dotfiles/docs/`.
Preview it locally:

```bash
mise run --cd ~/.config/dotfiles docs:serve
```

Or build the static site:

```bash
mise run --cd ~/.config/dotfiles docs:build
```

## License

Licensed under the [Apache License, Version 2.0](LICENSE).
