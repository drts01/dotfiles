+++
title = "Customize the shell"
description = "Add aliases, environment settings, and tool integrations for POSIX sh, Bash, and Zsh."
weight = 50

[extra]
type = "how-to"
+++

Add aliases, environment settings, and tool integrations that load in every shell that supports them.

## Prerequisites

- Installed dotfiles and the `dotfiles` alias.
- The file that owns the setting; see [Shell files](@/docs/reference/shell.md).

## Add a portable alias

1. Edit `~/.config/sh/sh.d/20_aliases.sh`.
2. Guard the alias with `has`, so shells without the tool skip it:

   ```sh
   has lazygit && alias lg='lazygit'
   ```

Put environment variables and `PATH` entries in `~/.config/sh/profile.d/20_env.sh` instead;
use `path_add` to add a directory once.
Use POSIX syntax only in these files; POSIX `sh` loads them too.

## Add a Bash or Zsh integration

Guard shell-specific code with `case $_shell`, and cache generated code with `source_cache`:

```sh
case $_shell in
  bash | zsh) source_cache "$XDG_CACHE_HOME/shell/direnv.$_shell" direnv hook "$_shell" ;;
esac
```

`source_cache` skips missing tools, and regenerates the cache when the tool's executable is newer.
For Zsh-only settings, add a `*.zshrc` file to `~/.config/zsh/zsh.d/`; files load in lexical order.

## Add a machine-local module

Create an untracked file, for example `~/.config/sh/sh.d/95_local.sh`.
Interactive shells source every `*.sh` file in `sh.d/`, and `dotfiles status` hides untracked files,
so the module stays on this machine.
Add tracked files by name; `dotfiles add -A` would track the local module.

## Reload and verify

Start a new login shell, then check the change:

```bash
exec "$SHELL" -l
alias lg
```

Test POSIX `sh` separately:

```bash
ENV="$XDG_CONFIG_HOME/sh/.shrc" sh -i
```

## Track the change

```bash
cd ~
dotfiles status
dotfiles add .config/sh/sh.d/20_aliases.sh
dotfiles commit -m "feat(sh): add lazygit alias"
dotfiles push
```

Push before the next [update](@/docs/how-to/update.md); updates fast-forward only.

## Undo

Discard an uncommitted change:

```bash
cd ~ && dotfiles restore .config/sh/sh.d/20_aliases.sh
```

Force a cached integration to regenerate by deleting its file under `$XDG_CACHE_HOME/shell/`.

## Related

- [Shell startup](@/docs/concepts/shell-startup.md)
- [Shell files](@/docs/reference/shell.md)
