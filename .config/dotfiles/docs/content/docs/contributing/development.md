+++
title = "Set up a development clone"
description = "Clone the repository, install development tooling with mise, and run the checks."
weight = 10

[extra]
type = "how-to"
+++

Change and test the dotfiles from a regular clone, never from the installed `$HOME`.
The full workflow lives in [CONTRIBUTING.md](https://github.com/drts01/dotfiles/blob/trunk/.github/CONTRIBUTING.md).

## Prerequisites

- Git and a POSIX `sh`.
- [mise](https://mise.jdx.dev); setup installs `prek`, and test tasks install ShellSpec on demand.
- Bash and Zsh for shell tests; Podman or Docker for container tests.

The documentation theme submodule is required for site builds; `docs:build` and `docs:serve` initialize it.

## Steps

1. Clone the repository:

   ```bash
   git clone https://github.com/drts01/dotfiles
   cd dotfiles
   ```

2. Set up the clone; rerun it at any time:

   ```bash
   sh .config/dotfiles/dev-setup.sh
   ```

3. List the development tasks:

   ```bash
   mise tasks ls
   ```

Do not run the installer, `mise-tasks/bootstrap.sh`, `install:gitignore`, or `install:git-hooks` in a clone;
they target the bare repository.

## Verify

```bash
mise run lint
mise run docs:build
```

## Related

- [Test the dotfiles](@/docs/contributing/testing.md)
- [Write documentation](@/docs/contributing/documentation.md)
- [CONTRIBUTING.md: Run tasks](https://github.com/drts01/dotfiles/blob/trunk/.github/CONTRIBUTING.md#run-tasks)
