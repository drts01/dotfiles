# Dotfiles tooling

Contains the bootstrap, maintenance tasks, tests, and documentation source for these dotfiles.
Bootstrap deploys this directory to `~/.config/dotfiles`.

- Install or update the dotfiles: read the [repository README](../../.github/README.md).
- Change or test the dotfiles: read [CONTRIBUTING.md](../../.github/CONTRIBUTING.md).
- Look up full reference material: read the [documentation site](https://drts01.github.io/dotfiles/).

## Layout

| Path                  | Purpose                                                                 |
| --------------------- | ----------------------------------------------------------------------- |
| `bootstrap.sh`        | Remote one-line installer; fetches and runs `mise-tasks/bootstrap.sh`   |
| `mise-tasks/`         | Installed task scripts: bootstrap/update, doctor, hooks, ignore link    |
| `mise.toml`           | Installed task definitions and deployment tool settings                 |
| `mise.lock`           | Shared tool lockfile for deployment and development                     |
| `dev-setup.sh`        | One-time setup for a regular development clone                          |
| `dev-tasks.toml`      | Development tasks: lint, tests, benchmarks, documentation builds        |
| `dev-miserc.toml`     | Template for the clone's ignored root `.miserc.toml`                    |
| `dev-mise-local.toml` | Template for the clone's ignored root `mise.local.toml`                 |
| `prek.toml`           | Git hook and lint configuration                                         |
| `gitignore`           | Ignore rules linked into Git's `info/exclude`                           |
| `.typos.toml`         | Spell-check configuration                                               |
| `.shellspec`          | ShellSpec options                                                       |
| `spec/`               | ShellSpec unit and shell startup specs                                  |
| `tests/`              | Bootstrap, submodule selection, doctor, container, and mise smoke tests |
| `bench/`              | Shell startup benchmark and profile analysis                            |
| `docs/`               | Zola documentation site source; theme is an optional submodule          |
| `LICENSE`             | Apache License, Version 2.0                                             |

## Common commands

Check an installed system:

```bash
sh ~/.config/dotfiles/mise-tasks/doctor.sh
```

Update an installed system:

```bash
mise run --cd ~/.config/dotfiles update
```

Run development tasks from the root of a configured clone with `mise run <task>`;
see [CONTRIBUTING.md](../../.github/CONTRIBUTING.md#run-tasks) for the task list.

## Constraints

- Keep `bootstrap.sh` and `mise-tasks/bootstrap.sh` dependent only on Git, a POSIX shell, and curl or wget.
- Do not run `mise-tasks/bootstrap.sh` or `install-hooks` in a development clone; they target the bare repository.
