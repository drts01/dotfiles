+++
title = "Hooks"
description = "Pre-commit hooks configured for the dotfiles repository."
weight = 40

[extra]
type = "reference"
+++

Hooks defined in `.config/dotfiles/prek.toml` and run by [`prek`](https://github.com/j178/prek) on every commit.

| Repository                                                     | Hooks                                                                                                   |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `meta`                                                         | `check-hooks-apply`, `check-useless-excludes`                                                           |
| `builtin`                                                      | Large files, case conflicts, shebangs, JSON/YAML/TOML, merge conflicts, symlinks, whitespace, line ends |
| `builtin`                                                      | `detect-private-key`: blocks files with a private key header (PEM, OpenSSH, PuTTY, PGP)                 |
| [`typos`](https://github.com/crate-ci/typos)                   | Spelling, with automatic fixes                                                                          |
| [`shfmt`](https://github.com/scop/pre-commit-shfmt)            | Shell script formatting                                                                                 |
| [`shellcheck`](https://github.com/shellcheck-py/shellcheck-py) | Shell script linting                                                                                    |
| [`tombi`](https://github.com/tombi-toml/tombi-pre-commit)      | TOML formatting                                                                                         |
| [`ryl`](https://github.com/owenlamont/ryl-pre-commit)          | YAML and Markdown linting, with a GitHub-annotated variant on the `manual` stage                        |
| [`vale`](https://github.com/vale-cli/vale)                     | Documentation prose: the house style in `.config/dotfiles/docs/vale/`                                   |

Fixers, such as `typos`, `end-of-file-fixer`, and `ryl`, rewrite files in place.
