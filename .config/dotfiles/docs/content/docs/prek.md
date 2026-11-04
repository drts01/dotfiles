+++
title = "Git hooks (prek)"
description = "Install and run the pre-commit hooks for the bare repository."
weight = 4
+++

Run formatting, linting, and spelling checks on every commit to the dotfiles.
The hooks use [`prek`](https://github.com/j178/prek), configured in `.config/dotfiles/prek.toml`.

## Install hooks

Prerequisites: `prek` on `PATH`, or mise to install the locked version.

Bootstrap installs the hooks automatically when either is available.
Install or repair them manually with mise:

```bash
mise run --cd ~/.config/dotfiles install-hooks
```

Without mise, run the script from the configuration directory:

```bash
cd ~/.config/dotfiles && sh mise-tasks/install-hooks.sh
```

The script runs `prek install`, then patches the generated hook to export `GIT_DIR` and `GIT_WORK_TREE`.
A bare repository checked out against `$HOME` has no `.git` directory, so Git cannot find it from the hook otherwise.

Verify the install with the [doctor](@/docs/bootstrap.md#verify-the-install);
it fails if the hook lacks the bare-repository overrides.

In a development clone, `sh .config/dotfiles/dev-setup.sh` installs ordinary hooks instead.

## Run hooks

Run every hook against all tracked files.
`prek` cannot find a bare repository from `$HOME` on its own, so set `GIT_DIR` and `GIT_WORK_TREE`:

```bash
cd ~ && GIT_DIR="$HOME/.local/share/dotfiles" GIT_WORK_TREE="$HOME" \
  prek run --config .config/dotfiles/prek.toml --all-files
```

Fixers such as `typos`, `end-of-file-fixer`, and `ryl` rewrite files in place; review `dotfiles diff` afterwards.

In a development clone, run `mise run lint`.

## Configured hooks

| Repository                                                     | Hooks                                                                                                   |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `meta`                                                         | `check-hooks-apply`, `check-useless-excludes`                                                           |
| `builtin`                                                      | Large files, case conflicts, shebangs, JSON/YAML/TOML, merge conflicts, symlinks, whitespace, line ends |
| [`typos`](https://github.com/crate-ci/typos)                   | Spelling, with automatic fixes                                                                          |
| [`shfmt`](https://github.com/scop/pre-commit-shfmt)            | Shell script formatting                                                                                 |
| [`shellcheck`](https://github.com/shellcheck-py/shellcheck-py) | Shell script linting                                                                                    |
| [`tombi`](https://github.com/tombi-toml/tombi-pre-commit)      | TOML formatting                                                                                         |
| [`ryl`](https://github.com/owenlamont/ryl-pre-commit)          | YAML and Markdown linting, with a GitHub-annotated variant on the `manual` stage                        |
| [`vale`](https://github.com/vale-cli/vale)                     | Documentation prose: the house style in `.config/dotfiles/docs/vale/`                                   |

## Why prek

`prek` reads the same hook definitions as Python `pre-commit`, here in TOML.
It is a single binary, so mise installs and pins it like any other tool, without a Python runtime.
