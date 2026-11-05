+++
title = "drts01/dotfiles"
description = "Personal dotfiles managed via a Git bare repository"

[extra.devlab.home]
layout = "wide"

[[extra.devlab.home.blocks]]
type = "hero"
eyebrow = "Dotfiles documentation"
actions = [
  { label = "Install", path = "@/docs/start/install.md" },
  { label = "Read the docs", path = "@/docs/_index.md" },
]

[[extra.devlab.home.blocks]]
type = "features"
items = [
  { kicker = "Start", title = "Install", path = "@/docs/start/install.md", description = "Deploy the dotfiles with Git and a POSIX shell, then confirm that they load." },
  { kicker = "Customize", title = "Shell", path = "@/docs/how-to/customize-shell.md", description = "Add aliases, settings, and integrations for sh, Bash, and Zsh." },
  { kicker = "Contribute", title = "Development", path = "@/docs/contributing/development.md", description = "Change and test the dotfiles from a regular clone." },
]

[[extra.devlab.home.blocks]]
type = "content"
+++

Use one shell and tool configuration on every machine you work on, with only Git and a POSIX shell.
`$HOME` is the Git working tree: no root access, symlinks, templating, or dotfiles manager.
Optional tools such as mise add features; the dotfiles work without them.
CI installs the dotfiles on six platforms on every push.

Compare this with other tools in [Is this approach right for you?](@/docs/concepts/compare-approaches.md)

A bare Git repository at `~/.local/share/dotfiles` tracks files such as `.profile` and `.config/` in place,
without symlinks or a separate clone; see [The bare repository](@/docs/concepts/bare-repo.md).

## Use the repository

```bash
dotfiles status
dotfiles add .config/helix/config.toml
dotfiles commit -m "feat(helix): update config"
dotfiles push
```

`dotfiles` is Git for the bare repository, defined in `.config/sh/sh.d/20_aliases.sh`.
