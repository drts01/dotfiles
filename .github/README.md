# Dotfiles

Manage system environment configurations via a Git bare repository.

## Features

- Manage local environment without root access
- No dependencies other than Git, a POSIX shell, and curl or wget for the one-line install
- Support shells: Bourne, Bash, Zsh

mise is not required to deploy the dotfiles. mise only manages CLI tools and git hooks after deployment.

## Installation

Run the bootstrap script to deploy configuration files onto a fresh machine:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

This installs [mise](https://mise.jdx.dev)
(a failed install only warns),
clones the bare repo to `~/.local/share/dotfiles`, checks out the tracked files into `$HOME`
(backing up any conflicting pre-existing files to `~/.df-bak`),
syncs submodules, and installs `prek` git hooks when available.
Re-running the command is safe: it fast-forwards the existing checkout instead of re-cloning.

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
dotfiles commit --message "feat(nvim): update config"
dotfiles push
```

Pull the latest dotfiles, sync submodules, then install CLI tools from `~/.config/mise`:

```bash
mise run --cd ~/.config/dotfiles update
```

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
