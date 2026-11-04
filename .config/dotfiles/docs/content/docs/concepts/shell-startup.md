+++
title = "Shell startup"
description = "How POSIX sh, Bash, and Zsh load one shared configuration, and why the order matters."
weight = 30

[extra]
type = "explanation"
+++

One set of portable modules serves POSIX `sh`, Bash, and Zsh.
Each shell reaches those modules through its own startup files, then adds what only it supports.

## The shared model

POSIX defines two hooks: a login shell reads `.profile`, and an interactive shell sources the file named in `$ENV`.
The dotfiles build on both:

- `.profile` sets XDG paths and the environment, then exports `ENV=.config/sh/.shrc`.
- `.config/sh/.shrc` returns early in non-interactive shells, so `scp`, `rsync`, and cron jobs stay quiet,
  then sources every `sh.d/*.sh` module in order.

POSIX does not standardize history, completion, or prompt hooks.
POSIX `sh` therefore gets portable aliases, environment variables, mise shims, search defaults, and Zoxide only.

## Zsh

```text
.zshenv
  └─ set ZDOTDIR
.config/zsh/.zprofile                 login shells only
  ├─ source .profile
  └─ configure Homebrew paths
.config/zsh/.zshrc                    interactive shells only
  ├─ configure Homebrew completions and run compinit
  ├─ source $ENV → .config/sh/.shrc (all shared modules in order)
  └─ source .config/zsh/zsh.d/*.zshrc in lexical order
```

`compinit` runs before the shared modules, so Skim, FZF, and `kubectl` can register completions.
Atuin loads after `zsh-autosuggestions`.

## Bash

```text
.bash_profile                         interactive login shells
  └─ source .bashrc
.bashrc                               all interactive Bash shells
  ├─ source .profile
  ├─ source .config/sh/.shrc
  └─ configure Bash history and OSC 133 prompt hooks
```

Bash reads `.bash_profile` instead of `.bashrc` for login shells, so `.bash_profile` must exist and delegate.
Bash ignores `$ENV` during normal interactive startup, so `.bashrc` sources `.shrc` directly.

## POSIX `sh`

```text
.profile
  ├─ configure XDG paths
  ├─ source profile.d/*.sh
  └─ export ENV=.config/sh/.shrc
.config/sh/.shrc                      interactive shells
  └─ source sh.d/*.sh
```

## Detecting the shell

`profile.d/10_functions.sh` sets the read-only `_shell` variable to `zsh`, `bash`, or `sh` once per process.
Modules branch on `case $_shell` and keep shell-specific syntax out of portable branches,
so every module parses in every shell.

## History

Each shell writes its own file under `$XDG_STATE_HOME`.
Zsh extended history uses a format that Bash cannot read, so a shared file would corrupt both.
`sh.d/10_interactive.sh` sets the capacity for every interactive shell, including non-login children;
each shell's native file sets its own controls. macOS `/bin/sh` is Bash in POSIX mode and
therefore writes `.bash_history`.

## mise: shims and activation

The profile puts the static shims directory first on `PATH`, ahead of Homebrew, so mise-managed versions win.
Shims work in every shell and in non-interactive commands. mise has no `activate sh` target,
so POSIX `sh` uses shims only.

Interactive Bash and Zsh also run `mise activate`, which adds directory and prompt hooks at a runtime cost.
Without mise, the shims entry resolves nothing.

## Cached initialization

Tools such as Zoxide and Starship print initialization code on every start.
`source_cache` saves that output under `$XDG_CACHE_HOME/shell/` and sources the saved copy:

- It regenerates when the cache is missing, empty, or older than the tool's executable.
- It writes to a temporary file and renames it, so a failed run keeps the previous cache.
- Under Zsh, it byte-compiles the cache with `zcompile`.

## Related

- [Customize the shell](@/docs/how-to/customize-shell.md)
- [Shell files](@/docs/reference/shell.md)
