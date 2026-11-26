+++
title = "Changelog"
description = "Breaking changes and the one-time migrations they need."
weight = 90

[extra]
type = "reference"
+++

Breaking changes, newest first.
Routine updates need no action beyond [Update the dotfiles](@/docs/how-to/update.md).

## 2026-11-25: Vim fallback uses native packages and private state

Vim now uses `.config/vim/vimrc` and pinned native packages instead of vim-plug.
Helix remains the primary editor.
The new `vim` plugin group is selected by `auto` and `all` when `vim` is installed;
explicit group lists remain unchanged.

- Start a new shell to load the guarded `vim()` wrapper for older Vim.
  It is defined only when the Vim executable and XDG `vimrc` exist, and supplies process-local `VIMINIT`
  only when unset; an existing value, including empty, is preserved.
  No global `VIMINIT` is exported, so `nvim` is unaffected.
  Use `command vim` for native discovery; scripts launching older Vim outside the configured shell need explicit `-u`.
  No `~/.vimrc` is required.
- Initialize packages with `DOTFILES_SUBMODULES=vim sh ~/.config/dotfiles/mise-tasks/bootstrap.sh`.
  Skip them with `DOTFILES_SKIP_SUBMODULES=vim` if not needed.
  The packages include the shallow `start/vim-repeat` submodule for repeatable GitGutter actions.
- Keep existing vim-plug content in `~/.vim` if needed for other configurations;
  deployment leaves it untouched, and the new managed configuration does not use it.
- Find new recovery files under `$XDG_STATE_HOME/vim/` or `~/.local/state/vim/`,
  with new directories created as mode `0700`.
- Enable LSP explicitly per session with `:VimLspEnable` on Vim 9+.
  Install servers separately; Vim reuses executables from `PATH` and downloads none.
  The LSP client routes diagnostics through ALE when installed (`aleSupport=true`);
  `ale_disable_lsp=1` prevents ALE from starting duplicate language-server processes.
  Ruff CLI linting remains enabled. Neither ALE fixers nor LSP formatting run on save;
  trailing-whitespace cleanup still runs for modifiable normal buffers except Markdown.

See [Use Vim as a fallback](@/docs/how-to/vim.md) and [Vim settings](@/docs/reference/vim.md).

## 2026-11-03: installer rejects unauthenticated transports

The entrypoint and the deploy script stop when `REPO_URL` starts with `http://`, `git://`, or `ftp://`.
Installs that use the default URL need no migration.

If you install from a mirror over one of those transports, pass an `https://` or `ssh://` `REPO_URL` instead.
Updates pull from the `origin` remote, so switch it as well:

```bash
git --git-dir="$HOME/.local/share/dotfiles" remote set-url origin https://git.example.com/dotfiles
```

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
