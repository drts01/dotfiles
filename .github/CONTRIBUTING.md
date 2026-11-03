# Contributing

Develop and test changes to these dotfiles from a regular clone.
Use the bare-repository install only for deploying them into `$HOME`.

## Prerequisites

- Git
- A POSIX shell, Bash, and Zsh
- [mise](https://mise.jdx.dev); development setup installs prek and ShellSpec
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

Set up the development clone (re-runnable):

```bash
sh .config/dotfiles/dev-setup.sh
```

This links the clone's Git exclude file to `.config/dotfiles/gitignore`,
copies `.config/dotfiles/dev-miserc.toml` and `.config/dotfiles/dev-mise-local.toml` to ignored root `.miserc.toml`
and `mise.local.toml`, installs prek and ShellSpec with mise, and installs ordinary pre-commit hooks into the clone.
Run this before invoking mise in the clone:
the root `.miserc.toml` prevents mise from treating the clone's `.config/mise` as a project config.
Setup links the ignored root `mise.local.lock` to the tracked `.config/dotfiles/mise.lock`.
Both configurations require locked installs.
The deployment config keeps only prek enabled;
its other tool declarations retain the development tools in the shared lock without installing them by default.
If either local config already exists with different contents, setup stops rather than overwriting it.
Compare it with the tracked template and merge changes manually before re-running setup.
If `mise.local.lock` already exists and points elsewhere, reconcile it manually.

## Run tasks

Define installed-dotfiles tasks in `.config/dotfiles/mise.toml` and `.config/dotfiles/mise-tasks/`;
keep development tasks in `.config/dotfiles/dev-tasks.toml`.
The clone-local `mise.local.toml` includes those tasks, so run them from the repository root:

```bash
mise tasks ls
mise run <task>
```

| Task                       | Purpose                                                       |
| -------------------------- | ------------------------------------------------------------- |
| `lint`                     | Run all `prek` hooks on tracked files                         |
| `shell:test`               | Run all ShellSpec unit and startup specs                      |
| `shell:bench`              | Benchmark isolated warm shell startup                         |
| `bootstrap:test`           | Test bootstrap in throwaway home directories                  |
| `bootstrap:test:container` | Test bootstrap and shell specs as non-root in containers      |
| `shell:test:posix`         | Run POSIX unit and startup specs                              |
| `shell:test:bash`          | Run Bash unit and startup specs                               |
| `shell:test:zsh`           | Run Zsh unit and startup specs                                |
| `docs:serve`               | Preview the documentation site                                |
| `docs:build`               | Build the documentation site                                  |

Update tool pins from the root of a configured development clone:

```bash
mise lock --bump
mise lock --dry-run --json
mise --cd .config/dotfiles lock --dry-run --json
```

Both dry runs should return `[]`.
The first updates the shared tracked lockfile;
the second checks that the deployment config still retains every development tool.
CI checks both views of the lockfile before linting.

Preview the lint task command without changing files:

```bash
mise run --dry-run lint
```

`lint` applies auto-fixes.
Commit or stash unrelated work before running it.

## Install git hooks

`dev-setup.sh` installs hooks into the regular clone.
To reinstall them without rerunning setup:

```bash
prek install --config .config/dotfiles/prek.toml
```

Do not use `mise run install-hooks` in a clone:
that task patches hooks for the bare repository in `~/.local/share/dotfiles`.

## Ignore local files

Development setup links this clone's `.git/info/exclude` to the tracked `.config/dotfiles/gitignore`.
The bare-repository bootstrap installs the same link at `~/.local/share/dotfiles/info/exclude`.
Git reads `info/exclude` only for its own repository, so these rules do not affect other repos under `$HOME`.
Changes to the tracked list take effect immediately in both installs after a pull; no link update is needed.
The installer backs up Git's comment-only default file to `exclude.before-dotfiles`.
If `info/exclude` contains local rules or is already a different symlink, it leaves it unchanged and prints a warning.
Keep rules specific to a directory in that directory's `.gitignore`,
and use `~/.config/git/ignore` for rules shared by all repositories.
Ignore rules do not hide tracked files; untrack them first if necessary.

## Validate changes

Run the checks that match the change:

| Change                       | Run                                                     |
| ---------------------------- | ------------------------------------------------------- |
| Any tracked file             | `mise run lint`                                         |
| `.profile`, `.bashrc`, Zsh   | `mise run shell:test`                                   |
| Shell unit specs             | `cd .config/dotfiles && shellspec --shell sh spec/unit` |
| Shell startup specs          | `cd .config/dotfiles && shellspec spec/startup`         |
| `bootstrap.sh`, `mise-tasks` | `mise run bootstrap:test`                               |
| `mise-tasks/doctor.sh`       | `sh .config/dotfiles/tests/doctor.sh`                   |
| Bootstrap portability        | `mise run bootstrap:test:container`                     |
| Documentation site           | `mise run docs:build`                                   |

CI runs lint and the isolated doctor test, `spec/unit` under `sh`, `bash`, and `zsh` on Ubuntu and macOS,
`spec/startup` once per host, and bootstrap tests on hosts and in containers on every push.
Failed ShellSpec jobs upload JUnit reports.
Container tests mount the mise-installed ShellSpec distribution read-only and run POSIX specs plus Bash specs
when available (`TEST_BASH=required|skip|auto`).
See `.github/workflows/ci.yaml`.

## Respect the deployment model

Every tracked file is checked out into `$HOME`.

- Place repository-only files under `.config/dotfiles/` or `.github/`.
- Avoid tracked top-level files; they land directly in `$HOME`.
  Development setup creates ignored root configs only in a clone.
- Keep tool configs that search parent directories (`.taplo.toml`, `tombi.toml`) out of the root;
  in `$HOME` they apply to every project below it.
- Start every `.editorconfig` section glob with `/` (for example `[/.config/sh/**]`).
  Anchored globs match only files tracked here; `[*.sh]` would match scripts in every project under `$HOME`.
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
