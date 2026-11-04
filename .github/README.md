# Dotfiles

Manage system environment configurations via a Git bare repository.

## Features

- Manage local environment without root access
- No dependencies other than Git and a POSIX shell; the one-line install also uses curl
- Support shells: Bourne, Bash, Zsh

Mise is optional; the installer needs curl or wget to fetch it, but Git and a POSIX shell suffice to use the dotfiles.
The one-line command below also needs curl to fetch the entrypoint.

## Choose a workflow

| Goal                          | Start here                                                                                                            |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Use these dotfiles in `$HOME` | Follow [Installation](#installation) to deploy the bare repository.                                                   |
| Change or test the dotfiles   | Follow [Contributing](CONTRIBUTING.md) to set up a regular development clone; do not run the installer in that clone. |

## Installation

Deploy the configuration files into `$HOME` (requires git and a POSIX shell):

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

The installer fetches the repository with git, runs its deploy script from that same commit,
and moves conflicting files to `~/.df-bak`.
It tries to install optional [mise](https://mise.jdx.dev) with curl or wget;
a missing downloader or failed install only warns.
Plugin submodules are initialized only for selected tools on `PATH`.
Re-running the command is safe: it fast-forwards the existing checkout.

To review the script first, pin a commit, choose plugin groups, set `DOTFILES_SKIP_MISE_INSTALL=1`,
or install with git alone, see [Bootstrap](https://drts01.github.io/dotfiles/docs/bootstrap/).

Verify the install (with or without mise):

```bash
sh ~/.config/dotfiles/mise-tasks/doctor.sh
```

## Usage

Manage tracked files with the `dotfiles` alias, a `git` wrapper for the bare repository:

```bash
dotfiles status
dotfiles add .config/helix/config.toml
dotfiles commit --message "feat(helix): update config"
```

Pull the latest dotfiles and initialize submodules for available tools (without mise):

```bash
sh ~/.config/dotfiles/mise-tasks/bootstrap.sh
```

If mise is installed, `mise run --cd ~/.config/dotfiles update` runs the same update task.

Update the machine toolchain separately with `mise --cd ~/.config/mise bootstrap`.

## Documentation

Read the full documentation at [drts01.github.io/dotfiles](https://drts01.github.io/dotfiles/):

- [Bootstrap](https://drts01.github.io/dotfiles/docs/bootstrap/): install options, environment variables, mise tasks,
  testing
- [Shell environments](https://drts01.github.io/dotfiles/docs/shell/): POSIX `sh`, Bash, and Zsh startup and maintenance
- [Neovim (legacy)](https://drts01.github.io/dotfiles/docs/nvim/): legacy editor configuration
- [Git hooks](https://drts01.github.io/dotfiles/docs/prek/): `prek` setup for the bare repository

Source: [`.config/dotfiles/docs/`](../.config/dotfiles/docs/).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for developing from a clone, running tasks, and validating changes.

## License

Licensed under the [Apache License, Version 2.0](../.config/dotfiles/LICENSE).
