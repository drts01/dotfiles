# Dotfiles

Manage system environment configurations via a Git bare repository.

## Features

- Manage local environment without root access
- No dependencies other than Git, a POSIX shell, and curl or wget for the one-line install
- Support shells: Bourne, Bash, Zsh

mise is not required to deploy the dotfiles. mise only manages CLI tools and git hooks after deployment.

## Choose a workflow

| Goal                          | Start here                                                                                                            |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Use these dotfiles in `$HOME` | Follow [Installation](#installation) to deploy the bare repository.                                                   |
| Change or test the dotfiles   | Follow [Contributing](CONTRIBUTING.md) to set up a regular development clone; do not run the installer in that clone. |

## Installation

Run the bootstrap script to deploy configuration files onto a fresh machine:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

This installs [mise](https://mise.jdx.dev)
(a failed install only warns),
clones the bare repo to `~/.local/share/dotfiles`, checks out the tracked files into `$HOME`
(backing up any conflicting pre-existing files to `~/.df-bak`),
initializes all 25 submodules in a separate, reported stage, and installs `prek` git hooks when available.
Re-running the command is safe: it fast-forwards the existing checkout instead of re-cloning.

To defer plugin downloads or select a group, set `DOTFILES_SUBMODULES` on the shell reading the pipe:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SUBMODULES=none sh
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SUBMODULES=zsh,nvim sh
```

Choose `all` (default), `none`, or a comma-separated list of `zsh` (Zsh plugins and `z.lua`), `nvim`
(Neovim plugins), and `docs` (documentation theme).
Neovim and Zsh start without plugins, but plugin features are unavailable until installed;
building the docs requires `docs`.
Install deferred groups later by rerunning `DOTFILES_SUBMODULES=all sh ~/.config/dotfiles/mise-tasks/bootstrap.sh`
(or substitute a group).
The choice applies only to that run: ordinary updates install all missing submodules,
and selecting `none` never removes previously installed ones.

Skip mise and deploy with git only:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | SKIP_MISE_INSTALL=1 sh
```

Without curl or wget, use git as the installer:

```bash
git clone --bare --single-branch --depth=1 https://github.com/drts01/dotfiles ~/.local/share/dotfiles
sh -c "$(git --git-dir="$HOME/.local/share/dotfiles" show HEAD:.config/dotfiles/mise-tasks/bootstrap.sh)"
```

Verify the install (with or without mise):

```bash
sh ~/.config/dotfiles/mise-tasks/doctor.sh
```

## Usage

Interact with the repository using the system alias:

```bash
dotfiles status
dotfiles add .config/nvim/init.lua
dotfiles commit --message "feat(nvim): update config"
dotfiles push
```

Pull the latest dotfiles, initialize missing submodules (all by default), and set up git hooks when available:

```bash
mise run --cd ~/.config/dotfiles update
```

Update the machine toolchain separately with `mise --cd ~/.config/mise bootstrap`.

## Documentation

Read the full documentation at [drts01.github.io/dotfiles](https://drts01.github.io/dotfiles/):

- [Bootstrap](https://drts01.github.io/dotfiles/docs/bootstrap/): install flow, environment variables, mise tasks,
  testing
- [Git hooks](https://drts01.github.io/dotfiles/docs/prek/): `prek` setup for the bare repository

Source: [`.config/dotfiles/docs/`](../.config/dotfiles/docs/).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for developing from a clone, running tasks, and validating changes.

## License

Licensed under the [Apache License, Version 2.0](../.config/dotfiles/LICENSE).
