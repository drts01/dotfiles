+++
title = "Git hooks (prek)"
weight = 4
+++

Hooks are managed with [`prek`](https://github.com/j178/prek) — a fast,
Rust-based pre-commit-compatible runner — configured in
`.config/dotfiles/prek.toml`.

## Why not plain pre-commit?

`prek` is a drop-in replacement for the Python `pre-commit` tool with the
same `.pre-commit-config.yaml`-style hook definitions (here in TOML), but
faster and installed as a single binary via `uv tool install` — see
[Bootstrap](/docs/bootstrap/#uv-tools).

## Configured hooks

| Repo | Hooks |
| --- | --- |
| `meta` | `check-hooks-apply`, `check-useless-excludes` |
| `builtin` | File hygiene: large files, case conflicts, shebangs, JSON/YAML/TOML validation, merge conflicts, symlinks, trailing whitespace, line endings |
| [`typos`](https://github.com/crate-ci/typos) | Spell-checking, auto-fix |
| [`shfmt`](https://github.com/scop/pre-commit-shfmt) | Shell script formatting |
| [`shellcheck`](https://github.com/shellcheck-py/shellcheck-py) | Shell script linting |
| [`tombi`](https://github.com/tombi-toml/tombi-pre-commit) | TOML formatting |
| [`ryl`](https://github.com/owenlamont/ryl-pre-commit) | YAML/Markdown linting, with a GitHub-annotated variant on the `manual` stage |

## Bare-repo hook injection

Because this repo is checked out as a bare repository against `$HOME`
rather than a normal working copy, the pre-commit hook that `prek install`
generates needs `GIT_DIR`/`GIT_WORK_TREE` explicitly set — otherwise git
can't locate the repo when the hook runs. `.config/dotfiles/scripts/install-hooks.sh`
patches the generated hook to export these after installation.

Re-run this patch at any time with:

```bash
mise run --cwd ~/.config/dotfiles install-hooks
```
