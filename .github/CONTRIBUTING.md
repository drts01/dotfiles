# Contributing

Develop and test changes to these dotfiles from a regular clone.
Use the bare-repository install only for deploying them into `$HOME`.

## Prerequisites

- Git
- A POSIX shell, Bash, and Zsh
- [mise](https://mise.jdx.dev)
- Podman or Docker for the container bootstrap tests

## Set up a working copy

Clone the repository with its submodules:

```bash
git clone --recurse-submodules https://github.com/drts01/dotfiles
cd dotfiles
```

Initialize submodules in an existing clone:

```bash
git submodule update --init --recursive
```

Install the pinned development tools:

```bash
mise --cd .config/dotfiles install
```

## Run tasks

Define tasks in `.config/dotfiles/mise.toml` and `.config/dotfiles/mise-tasks/`.
Run them from the repository root with `--cd`; plain `mise run` from the root does not load that config.

```bash
mise --cd .config/dotfiles tasks ls
mise --cd .config/dotfiles run <task>
```

| Task                       | Purpose                                                       |
| -------------------------- | ------------------------------------------------------------- |
| `lint`                     | Run all `prek` hooks on tracked files                         |
| `shell:test`               | Check shell syntax, caching, and isolated Zsh startup         |
| `shell:bench`              | Benchmark isolated warm shell startup                         |
| `bootstrap:test`           | Test bootstrap in throwaway home directories                  |
| `bootstrap:test:container` | Test bootstrap as non-root in containers; pass images to pick |
| `docs:serve`               | Preview the documentation site                                |
| `docs:build`               | Build the documentation site                                  |

Preview lint hooks without changing files:

```bash
mise --cd .config/dotfiles run lint --dry-run
```

`lint` applies auto-fixes.
Commit or stash unrelated work before running it.

## Install git hooks

Install hooks into the clone:

```bash
prek install --config .config/dotfiles/prek.toml
```

Skip `install-hooks` for clones.
That task patches hooks for the bare repository in `~/.local/share/dotfiles`.

## Validate changes

Run the checks that match the change:

| Change                       | Run                                                       |
| ---------------------------- | --------------------------------------------------------- |
| Any tracked file             | `mise --cd .config/dotfiles run lint`                     |
| `.profile`, `.bashrc`, Zsh   | `mise --cd .config/dotfiles run shell:test`               |
| `bootstrap.sh`, `mise-tasks` | `mise --cd .config/dotfiles run bootstrap:test`           |
| Bootstrap portability        | `mise --cd .config/dotfiles run bootstrap:test:container` |
| Documentation site           | `mise --cd .config/dotfiles run docs:build`               |

CI runs `lint`, `shell:test`, and the bootstrap tests on every push.
See `.github/workflows/ci.yaml`.

## Respect the deployment model

Every tracked file is checked out into `$HOME`.

- Place repository-only files under `.config/dotfiles/` or `.github/`.
- Avoid new top-level files; they land directly in `$HOME`.
- Keep tool configs that search parent directories (`.editorconfig`, `tombi.toml`, `.taplo.toml`) out of the root;
  in `$HOME` they apply to every project below it.
- Add plugins and themes as shallow submodules in `.gitmodules`.
- Keep `bootstrap.sh` dependent only on Git, a POSIX shell, and curl or wget.

## Documentation layout

| File                          | Purpose                                                         |
| ----------------------------- | --------------------------------------------------------------- |
| `.github/README.md`           | Repository landing page: install, basic usage, links            |
| `.github/CONTRIBUTING.md`     | Development workflow for clones                                 |
| `.config/dotfiles/docs/`      | Full reference site, published to GitHub Pages                  |
| `.config/dotfiles/LICENSE`    | License text                                                    |

GitHub detects `README.md` and `CONTRIBUTING.md` in `.github/`.
Add reference material to the documentation site, not the README.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org) with a scope:

```text
feat(zsh): add completion cache
fix(dotfiles): handle missing mise
test(shell): assert plugin startup
ci(ci): checkout submodules
docs(readme): update bootstrap
```
