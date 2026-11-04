+++
title = "Choose plugin groups"
description = "Select, exclude, or add the Zsh, Neovim, Lua, and docs plugin submodules."
weight = 20

[extra]
type = "how-to"
+++

Install only the plugins you use, and add skipped plugins later.

## Prerequisites

- The tool for each group you want on `PATH`: `zsh`, `nvim`, `lua` or `luajit`, or `zola`.
  The installer skips a group whose tool is missing, even when you select it.

By default, the installer selects `zsh`, `nvim`, and `lua` when their tools are present.
See [Plugin groups](@/docs/reference/environment.md#plugin-groups) for every group and its submodules.

## Exclude groups at install

Set `DOTFILES_SKIP_SUBMODULES` on the `sh` that reads the pipe:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SKIP_SUBMODULES=nvim,lua sh
```

Use `DOTFILES_SKIP_SUBMODULES=all` to skip every group.
Zsh and Neovim start without their plugins; plugin features stay unavailable.

## Select groups at install

Set `DOTFILES_SUBMODULES` to a comma-separated list:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SUBMODULES=zsh sh
```

Unknown group names fail before checkout.

## Add a group later

1. Install the group's tool.
2. Run the deploy script with the group selected:

   ```bash
   DOTFILES_SUBMODULES=nvim sh ~/.config/dotfiles/mise-tasks/bootstrap.sh
   ```

## Verify

List the submodules; a leading `-` marks one that is not initialized:

```bash
cd ~ && git --git-dir="$HOME/.local/share/dotfiles" --work-tree="$HOME" submodule status
```

## Undo

Both variables apply to one run; later runs without them detect tools again.
Skipping a group does not remove plugins that are already initialized.
To remove them, deinitialize the group's path from [Plugin groups](@/docs/reference/environment.md#plugin-groups):

```bash
cd ~ && git --git-dir="$HOME/.local/share/dotfiles" --work-tree="$HOME" submodule deinit -- .config/nvim/pack/plugins/start
```

## Related

- [Environment variables](@/docs/reference/environment.md)
- [Use the legacy Neovim configuration](@/docs/how-to/nvim.md)
