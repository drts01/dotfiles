+++
title = "Bootstrap"
weight = 1
+++

## Installation

```bash
curl -sL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

`bootstrap.sh` is intentionally minimal — it only does what must happen
before `mise` exists:

1. Clones the bare repo to `~/.local/share/dotfiles` (or pulls if it already
   exists), backing up any conflicting pre-existing files to `~/.df-bak`.
2. Syncs submodules.
3. Installs [mise](https://mise.jdx.dev).
4. Hands off to `mise run setup`, defined in `.config/dotfiles/mise.toml`.

## mise tasks

All post-clone work lives in `.config/dotfiles/mise.toml` and
`.config/dotfiles/scripts/`, so it's re-runnable independently of bootstrap:

| Task | Description |
| --- | --- |
| `setup` | Install `uv`-managed CLI tools ([`uv-tools`](#uv-tools)) and `prek` git hooks ([`install-hooks`](#install-hooks)) |
| `update` | Pull latest changes, sync submodules, and re-run `setup` |
| `doctor` | Verify required tools, the bare repo, and git hooks are correctly installed |

Run any task with:

```bash
mise run --cwd ~/.config/dotfiles <task>
```

### `uv-tools`

Installs every tool listed in `.config/dotfiles/uvfile.txt` via
`uv tool install`. The `uv` version itself is pinned in `mise.toml`
(`[tools] uv = "..."`).

### `install-hooks`

Runs `prek install` against `.config/dotfiles/prek.toml` and patches the
generated pre-commit hook so it targets the bare repo's `GIT_DIR`/
`GIT_WORK_TREE` instead of a normal working copy. See [Git hooks](/docs/prek/).

## Verifying an install

```bash
mise run --cwd ~/.config/dotfiles doctor
```

Checks that `git`, `mise`, `uv`, and `prek` are on `PATH`, the bare repo
exists, `dotfiles status` runs clean, the pre-commit hook is installed and
executable, and every tool in `uvfile.txt` is actually installed.
