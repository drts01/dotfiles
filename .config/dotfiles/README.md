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
dotfiles commit -m "feat(nvim): update config"
dotfiles push
```

### Updating

Pull the latest dotfiles, sync submodules, then install CLI tools with `mise bootstrap` from `~/.config/mise`:

```bash
mise run --cd ~/.config/dotfiles update
```

Without mise, re-run the deploy script to pull and sync:

```bash
sh ~/.config/dotfiles/mise-tasks/bootstrap.sh
```

### Available mise tasks

| Task                       | Description                                                                              |
| -------------------------- | ---------------------------------------------------------------------------------------- |
| `bootstrap`                | Check out or fast-forward dotfiles, sync submodules, and install `prek` git hooks        |
| `update`                   | Run `bootstrap`, then `mise bootstrap` from the global config (`~/.config/mise`)         |
| `doctor`                   | Verify required tools, the bare repo, and git hooks are correctly installed              |
| `bootstrap:test`           | Test bootstrap in throwaway home directories without mise, including a repeat run        |
| `bootstrap:test:container` | Run `bootstrap:test` as non-root in containers (podman or docker); pass images to select |

## Testing

Test the bootstrap on the host:

```bash
mise run --cd ~/.config/dotfiles bootstrap:test
```

Test it as a non-root user in clean containers.
Omit images to run all defaults:

```bash
mise run --cd ~/.config/dotfiles bootstrap:test:container
mise run --cd ~/.config/dotfiles bootstrap:test:container -- cgr.dev/chainguard/git:latest-dev
```

Default images: `buildpack-deps:stable-scm`, `alpine:latest`, `fedora:latest`, `cgr.dev/chainguard/git:latest-dev`.
CI runs one parallel job per image plus a macOS host job.
See the [bootstrap docs](docs/content/docs/bootstrap.md#testing) for engine selection and mirror overrides.

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
