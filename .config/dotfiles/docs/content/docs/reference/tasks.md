+++
title = "Tasks"
description = "mise tasks and scripts installed with the dotfiles."
weight = 20

[extra]
type = "reference"
+++

Tasks installed with the dotfiles, defined in `~/.config/dotfiles/mise.toml` and `~/.config/dotfiles/mise-tasks/`.
Development tasks live in a clone; see [Contributing](@/docs/contributing/development.md).

Run a task with mise from any directory:

```bash
mise run --cd ~/.config/dotfiles <task>
```

| Task            | Script without mise                                       | Description                                                              |
| --------------- | --------------------------------------------------------- | ------------------------------------------------------------------------ |
| `bootstrap`     | `sh ~/.config/dotfiles/mise-tasks/bootstrap.sh`           | Check out or pull, initialize selected submodules, install hooks         |
| `update`        | `sh ~/.config/dotfiles/mise-tasks/bootstrap.sh`           | Same as `bootstrap`; use it after the first install                      |
| `install-hooks` | `cd ~/.config/dotfiles && sh mise-tasks/install-hooks.sh` | Install the `prek` hook patched for the bare repository                  |
| `doctor`        | `sh ~/.config/dotfiles/mise-tasks/doctor.sh`              | Check the bare repository, tracked changes, and optional tools and hooks |
| `docs:lint`     | none                                                      | Check documentation prose against the house style; pass files to check   |

The deploy step installs only `prek`; `docs:lint` installs Vale on first use.
Both are pinned in `~/.config/dotfiles/mise.lock`.
