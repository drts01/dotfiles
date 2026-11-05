# Dotfiles

[![CI](https://github.com/drts01/dotfiles/actions/workflows/ci.yaml/badge.svg?branch=trunk)](https://github.com/drts01/dotfiles/actions/workflows/ci.yaml?query=branch%3Atrunk)
[![Documentation](https://github.com/drts01/dotfiles/actions/workflows/docs.yml/badge.svg?branch=trunk)](https://github.com/drts01/dotfiles/actions/workflows/docs.yml?query=branch%3Atrunk)

Personal dotfiles managed via a Git bare repository.

Use one shell and tool configuration on every machine you work on, with only Git and a POSIX shell.
`$HOME` is the Git working tree: no root access, symlinks, templating, or dotfiles manager.
Optional tools such as mise add features; the dotfiles work without them.
Supports POSIX `sh`, Bash, and Zsh; CI installs the dotfiles on six platforms on every push.

Compare this with other tools in
[Is this approach right for you?](https://drts01.github.io/dotfiles/docs/concepts/compare-approaches/)

## Choose a workflow

| Goal                          | Start here                                                                                                            |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Use these dotfiles in `$HOME` | Follow [Installation](#installation) to deploy the bare repository.                                                   |
| Change or test the dotfiles   | Follow [Contributing](CONTRIBUTING.md) to set up a regular development clone; do not run the installer in that clone. |

## Installation

Deploy the configuration files into `$HOME` (requires Git, a POSIX shell, and curl):

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

The installer fetches the repository with Git, runs its deploy script from that same commit,
and moves conflicting files to `~/.df-bak`.
It tries to install optional [mise](https://mise.jdx.dev) with curl or wget;
a missing downloader or failed install only warns.
Plugin submodules are initialized only for selected tools on `PATH`.
Re-running the command is safe: it fast-forwards the existing checkout.

To review the script first, pin a commit, choose plugin groups, set `DOTFILES_SKIP_MISE_INSTALL=1`,
or install with Git alone, see the [how-to guides](https://drts01.github.io/dotfiles/docs/how-to/).

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

Read the [full documentation](https://drts01.github.io/dotfiles/):

- [Start here](https://drts01.github.io/dotfiles/docs/start/install/): install on a new machine and verify
- [How-to guides](https://drts01.github.io/dotfiles/docs/how-to/): pin, update, customize, Helix, uninstall,
  troubleshoot
- [Concepts](https://drts01.github.io/dotfiles/docs/concepts/): comparison with other tools, the bare repository,
  the installer, shell startup, security
- [Reference](https://drts01.github.io/dotfiles/docs/reference/): variables, tasks, shell files, hooks, platforms,
  glossary
- [Changelog](https://drts01.github.io/dotfiles/docs/reference/changelog/): breaking changes and migrations

Source: [`.config/dotfiles/docs/`](../.config/dotfiles/docs/).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for developing from a clone, running tasks, and validating changes.

## Security

Report vulnerabilities privately; see [SECURITY.md](SECURITY.md).

## License

Licensed under the [Apache License, Version 2.0](../.config/dotfiles/LICENSE).
