# Dotfiles tooling

Contains the bootstrap, maintenance tasks, tests, and documentation source for these dotfiles.
Bootstrap deploys this directory to `~/.config/dotfiles`.

- Start with the [documentation site](https://drts01.github.io/dotfiles/) for installation, maintenance, and reference.
- For a quick install, read the [repository README](../../.github/README.md).
- To change or test the dotfiles, read [CONTRIBUTING.md](../../.github/CONTRIBUTING.md).

## Layout

| Path                  | Purpose                                                                   |
| --------------------- | ------------------------------------------------------------------------- |
| `bootstrap.sh`        | One-line installer; fetches a commit with Git and runs its deploy script  |
| `mise-tasks/`         | Installed task scripts: bootstrap/update, doctor, hooks, ignore link      |
| `mise.toml`           | Installed task definitions and deployment tool settings                   |
| `mise.lock`           | Deployment tool lockfile (prek only)                                      |
| `dev-mise.lock`       | Development tool lockfile; linked as `mise.local.lock` in a clone         |
| `dev-setup.sh`        | One-time setup for a regular development clone                            |
| `dev-tasks.toml`      | Development tasks: lint, tests, benchmarks, documentation builds          |
| `dev-miserc.toml`     | Target for the clone's ignored root `.miserc.toml`                        |
| `dev-mise-local.toml` | Target for the clone's ignored root `mise.local.toml`                     |
| `prek.toml`           | Git hook and lint configuration                                           |
| `gitignore`           | Ignore rules linked into Git's `info/exclude`                             |
| `.typos.toml`         | Spell-check configuration                                                 |
| `.shellspec`          | ShellSpec options                                                         |
| `spec/`               | ShellSpec unit and shell startup specs                                    |
| `tests/`              | Bootstrap, submodule selection, doctor, container, and mise smoke tests   |
| `bench/`              | Shell startup benchmark and profile analysis                              |
| `docs/`               | Zola documentation source, not the rendered site; `docs/run.sh` builds it |
| `LICENSE`             | Apache License, Version 2.0                                               |

## Constraints

- Keep `bootstrap.sh` and `mise-tasks/bootstrap.sh` dependent only on Git and a POSIX shell;
  curl or wget is needed only to fetch optional mise; the one-line entrypoint command itself requires curl.
- Do not run `mise-tasks/bootstrap.sh`, `install:gitignore`, or `install:git-hooks` in a development clone;
  they target the bare repository.
