+++
title = "Use Vim as a fallback"
description = "Load the fallback Vim configuration, refresh optional packages, and enable language servers for one session."
weight = 75

[extra]
type = "how-to"
+++

Use Vim when [Helix](@/docs/how-to/helix.md), the primary editor, is unavailable.
The managed configuration starts without plugins.

## Prerequisites

- Vim 8 or newer on `PATH`.
- Git and a POSIX `sh` for package initialization.
- Optional CLI tools on `PATH`; see [Vim settings](@/docs/reference/vim.md#external-tools).

## Load the configuration

1. Start a new shell after updating the dotfiles, then run `vim`.
   The shell defines a `vim()` wrapper only when the Vim executable and XDG `vimrc` exist.
   The wrapper supplies process-local `VIMINIT` only when the caller has not set it;
   an existing value, including an empty one, is preserved.
   This loads the configuration on older Vim without exporting `VIMINIT` globally or affecting `nvim`.
2. To bypass an existing `VIMINIT` or test the managed file directly, run:

   ```bash
   command vim -u "${XDG_CONFIG_HOME:-$HOME/.config}/vim/vimrc"
   ```

Use `command vim` to bypass the wrapper and use Vim's native configuration discovery.
Scripts launching older Vim outside the configured shell need the explicit `-u` path above.
No `~/.vimrc` is required.
Existing vim-plug files under `~/.vim` remain untouched but are unused by the new managed configuration.

## Refresh packages

On a deployed installation, initialize the pinned packages again after pulling changes that add or move them:

```bash
DOTFILES_SUBMODULES=vim sh ~/.config/dotfiles/mise-tasks/bootstrap.sh
```

The installer selects this group automatically when `vim` is on `PATH`.
It regenerates package help tags; a failure warns without aborting deployment.
To skip packages, see [Choose plugin groups](@/docs/how-to/choose-plugin-groups.md).
For a development clone, use the submodule command in [Development setup](@/docs/contributing/development.md#prerequisites).

## Use optional features

- Press `,n` to toggle Fern when available, or open `netrw` with `:Explore` otherwise.
  No file tree opens at startup.
- Press `Ctrl-p` for files or `,b` for buffers when `fzf` and its packages are available.
  Press `,f` for text search when `rg` is also available.
- Press `,a` to run ALE fixers explicitly. Neither ALE fixers nor LSP formatting run on save.
  Saving still removes trailing whitespace from modifiable normal buffers except Markdown.
- On Vim 9 or newer, run `:VimLspEnable` to enable LSP for the current session.
  Install the desired [language-server executable](@/docs/reference/vim.md#language-servers) first;
  the client reuses tools on `PATH`, including mise tools, and downloads nothing.
  When ALE is installed, LSP diagnostics appear through ALE; Ruff CLI linting remains enabled.

## Verify

Inside Vim:

- Run `:scriptnames` and confirm the managed `vim/vimrc` appears.
- Run `:set backupdir? directory? undodir?` and confirm recovery paths use the Vim state directory.
- Run `:ALEInfo` to inspect available CLI linters when ALE is initialized.
- Run `:help fugitive` after package initialization to check generated help tags.

See [Mappings](@/docs/reference/vim.md#mappings) for navigation, diagnostics, and Git commands.

## Undo

Run `vim -Nu NONE` for an unconfigured session.
Restart Vim without `:VimLspEnable` to leave LSP disabled.
Skipping the `vim` group does not remove initialized packages;
use the removal procedure in [Choose plugin groups](@/docs/how-to/choose-plugin-groups.md#undo).

## Related

- [Vim settings](@/docs/reference/vim.md)
- [Test Vim](@/docs/contributing/testing.md#test-vim)
