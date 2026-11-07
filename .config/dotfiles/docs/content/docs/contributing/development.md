+++
title = "Set up a development clone"
description = "Clone the repository, install development tooling with mise, and run the checks."
weight = 10

[extra]
type = "how-to"
+++

Change and test the dotfiles from a regular clone, never from the installed `$HOME`.
This site is the canonical guide to development;
[CONTRIBUTING.md](https://github.com/drts01/dotfiles/blob/trunk/.github/CONTRIBUTING.md) is the short GitHub entry
point.

## Prerequisites

- Git and a POSIX `sh`.
- [mise](https://mise.jdx.dev); setup installs `prek`, and test tasks install ShellSpec on demand.
- Bash and Zsh for shell tests; Podman or Docker for container tests.

The documentation theme submodule is required for site builds; `docs:build` and `docs:serve` initialize it.
Initialize Zsh plugins with `git submodule update --init -- .local/share/zsh` for plugin startup tests,
`git submodule update --init -- .local/share/z.lua` for Lua tests,
and `git submodule update --init -- .config/nvim/pack/plugins/start` for Neovim development.

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

Setup links the clone's Git exclude file to `.config/dotfiles/gitignore` and links ignored root `.miserc.toml`,
`mise.local.toml`, and `mise.local.lock` to their tracked development files.
It trusts the maintenance tasks, installs prek, and installs regular-clone pre-commit hooks.
Run setup before using mise in the clone so the machine configuration at `.config/mise/` does not load
as project configuration.
Setup replaces unchanged copies of `.miserc.toml` and `mise.local.toml`
(including a mise config with the former `locked = true` setting)
with symlinks; it stops rather than overwriting custom content or links to other targets.
It also stops if the lockfile already links elsewhere.
The deployed `.config/dotfiles/mise.lock` is separate; development tasks install ShellSpec on demand.

Do not run the installer, `mise-tasks/bootstrap.sh`, `install:gitignore`, or `install:git-hooks` in a clone;
they target the bare repository.
Reinstall the clone's hooks with `prek install --config .config/dotfiles/prek.toml`.

## Verify

```bash
mise run lint
mise run docs:build
```

## Tasks and tool pins

List tasks with `mise tasks ls` and run one with `mise run <task>` from the clone root.
Installed-dotfiles tasks are defined in `.config/dotfiles/mise.toml` and `.config/dotfiles/mise-tasks/`;
clone-only tasks live in `.config/dotfiles/dev-tasks.toml`.
Run `mise run --dry-run lint` to preview lint; `mise run lint` applies automatic fixes,
so review unrelated changes before running it.
The Vale hook uses the house style in `.config/vale/`.

Update pins from the configured clone root:

```bash
mise lock --bump
MISE_CEILING_PATHS="$PWD/.config" mise --cd .config/dotfiles lock --bump
mise lock --dry-run --json
MISE_CEILING_PATHS="$PWD/.config" mise --cd .config/dotfiles lock --dry-run --json
```

The bump commands update the tracked development and deployment locks separately.
Both dry runs should return `[]`; CI checks both locks.
The ceiling path prevents the deployment check from loading clone-only tasks.

## Protect the deployment model

Every tracked file lands in `$HOME`.
Place repository-only files under `.config/dotfiles/` or `.github/`; avoid tracked top-level files.
Keep tool configs that search parent directories out of the root: in `$HOME` they would apply to every project below it.
Start each `.editorconfig` section glob with `/` so it matches only files tracked here.
Add plugins and themes as shallow submodules in `.gitmodules`.
Keep `bootstrap.sh` dependent only on Git and a POSIX shell; curl or wget fetches optional mise,
and the one-line install uses curl to fetch its entrypoint.

Keep local-only ignore rules in each directory's `.gitignore`, and use `~/.config/git/ignore` for global rules.
Git's `info/exclude` link to `.config/dotfiles/gitignore` applies only to this clone
(or to the bare repository when installed).
It does not hide tracked files.

## Commit changes

Use [Conventional Commits](https://www.conventionalcommits.org) with a scope,
for example `fix(dotfiles): handle missing mise` or `docs(readme): update bootstrap`.

## Related

- [Test the dotfiles](@/docs/contributing/testing.md)
- [Write documentation](@/docs/contributing/documentation.md)
- [Hooks](@/docs/reference/hooks.md)
- [File layout](@/docs/reference/file-layout.md)
