+++
title = "drts01/dotfiles"
description = "Personal dotfiles managed via a Git bare repository; mise is optional."

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

Track your shell and tool configuration in Git, directly in `$HOME`.
Use Git and a POSIX shell; mise is optional.

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
