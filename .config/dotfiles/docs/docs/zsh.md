---
icon: lucide/terminal
---

# Zsh

Configuration lives under `.config/zsh/zsh.d/`, split into numbered files
loaded in order (lower numbers first):

| File | Purpose |
| --- | --- |
| `0_base.zshrc` | History options, vi keybindings, `$EDITOR`/`$PAGER` setup |
| `10_path.zshrc` | `$PATH` construction |
| `20_aliases.zshrc` | Shell aliases, including `dotfiles` |
| `100_homebrew.zshrc` | Homebrew environment setup (macOS) |
| `500_misc.zshrc` | Miscellaneous settings |
| `999_zsh.zshrc` | Loaded last — plugin sourcing, prompt, etc. |

## Key aliases

```bash
alias dotfiles='git --git-dir=$HOME/.local/share/dotfiles --work-tree=$HOME'
```

This is the primary way to interact with the tracked dotfiles — see
[Overview](index.md#interact-with-the-repo).

## Submodule-based plugins

`fast-syntax-highlighting`, `zsh-autosuggestions`, `spaceship-prompt`, and
`z.lua` are tracked as git submodules under `.local/share/zsh/` and
`.local/share/z.lua`, kept in sync the same way as [Neovim](nvim.md) plugins.
