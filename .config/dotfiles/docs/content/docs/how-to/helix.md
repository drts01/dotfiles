+++
title = "Set up Helix"
description = "Install Helix and its language servers, then confirm that the tracked configuration loads."
weight = 65

[extra]
type = "how-to"
+++

Get the tracked Helix configuration working with its formatters and language servers.
Helix is the primary editor; it needs no plugin submodules.

## Prerequisites

- An installed dotfiles checkout; the configuration is in `~/.config/helix/`.
- Helix (`hx`) on `PATH`.
- Optional: the language servers below.
  Helix runs without them and reports each missing one in its health check.

| Language            | Servers and formatters                                    | Installed by the mise toolchain      |
| ------------------- | --------------------------------------------------------- | ------------------------------------ |
| Markdown            | `rumdl`, `marksman`, `ryl`, `harper-ls`, `markdown-oxide` | All except `markdown-oxide`          |
| YAML                | `ryl`, `yaml-language-server`, `ansible-language-server`  | All except `ansible-language-server` |
| Bash                | `bash-language-server`, `shfmt`                           | All                                  |
| Git commit messages | `harper-ls`                                               | Yes                                  |

## Install Helix and the language servers

With mise, install the machine toolchain from `~/.config/mise/`, which includes Helix:

```bash
mise install
```

Without mise, install Helix from your package manager or from <https://helix-editor.com>,
then install the servers you need.

## Verify

The health check lists each configured server with `✓` when it is on `PATH`:

```bash
hx --health markdown
```

`✘` marks a missing server; Helix still opens files of that language without it.

## Change a setting

1. Edit `~/.config/helix/config.toml` for editor settings, or `~/.config/helix/languages.toml` for language servers.
2. Run `:config-reload` in Helix, or restart it.
3. Commit the change by name:

   ```bash
   cd ~ && dotfiles add .config/helix/config.toml && dotfiles commit
   ```

## Related

- [Update the dotfiles](@/docs/how-to/update.md)
- [Use the legacy Neovim configuration](@/docs/how-to/nvim.md)
- [File layout](@/docs/reference/file-layout.md)
