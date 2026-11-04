+++
title = "Changelog"
description = "Breaking changes and the one-time migrations they need."
weight = 90

[extra]
type = "reference"
+++

Breaking changes, newest first.
Routine updates need no action beyond [Update the dotfiles](@/docs/how-to/update.md).

## 2026-11-03: documentation restructured

Documentation URLs changed; the old URLs return 404.

| Old URL            | New pages                                                                                                                                            |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/docs/bootstrap/` | [Install](@/docs/start/install.md), [how-to guides](@/docs/how-to/_index.md), [How the installer works](@/docs/concepts/bootstrap-flow.md)           |
| `/docs/shell/`     | [Customize the shell](@/docs/how-to/customize-shell.md), [Shell startup](@/docs/concepts/shell-startup.md), [Shell files](@/docs/reference/shell.md) |
| `/docs/prek/`      | [Install and run Git hooks](@/docs/how-to/git-hooks.md), [Hooks](@/docs/reference/hooks.md)                                                          |
| `/docs/nvim/`      | [Use the legacy Neovim configuration](@/docs/how-to/nvim.md)                                                                                         |

## 2026-11-03: installer fetches with Git

- The entrypoint fetches the repository with Git and runs the deploy script from the fetched commit.
  `DOTFILES_REF` pins a branch, tag, or verified commit.
- `auto` no longer selects the `docs` plugin group; select it with `DOTFILES_SUBMODULES=docs` or `all`.
- `~/.df-bak` is created with mode `700`.

No migration is needed.

## 2026-10-31: deploy script stops writing `core.worktree`

Older deploy scripts write `core.worktree` to the bare repository after each pull, which makes Git warn.

Migrate once with the remote entrypoint; it replaces the installed script with one that removes the setting:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SKIP_MISE_INSTALL=1 sh
```

Do not run `mise run update` for this migration; it runs the old installed script, which restores the setting.

Verify that this command prints nothing:

```bash
git config --file "$HOME/.local/share/dotfiles/config" --get core.worktree
```
