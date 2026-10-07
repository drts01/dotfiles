+++
title = "Shell environments"
description = "Load and maintain shared POSIX sh, Bash, and Zsh configuration."
updated = 2026-10-07
weight = 3
+++

## Choose a shell

Use the configuration at these support levels:

| Shell | Support | Entry points |
| --- | --- | --- |
| Zsh | Full | `.zshenv`, `.config/zsh/.zprofile`, `.config/zsh/.zshrc` |
| Bash | Full | `.bash_profile`, `.bashrc` |
| POSIX `sh` | Baseline | `.profile`, `$ENV` → `.config/sh/.shrc` |

Use Zsh or Bash for completion, prompt, Atuin, SDKMAN, and language-manager hooks. Use POSIX `sh` for portable aliases, environment variables, Mise shims, search defaults, and Zoxide.

## Follow the startup paths

### Zsh

Load Zsh configuration in this order:

```text
.zshenv
  └─ set ZDOTDIR
.config/zsh/.zprofile                 login shells only
  ├─ source .profile
  └─ configure Homebrew paths
.config/zsh/.zshrc                    interactive shells only
  ├─ source $ENV → .config/sh/.shrc
  └─ source .config/zsh/zsh.d/*.zshrc in lexical order
```

Use these Zsh modules:

| File | Purpose |
| --- | --- |
| `0_base.zshrc` | Configure Zsh history behavior. |
| `10_completion.zshrc` | Load cached completion and rebuild it after 24 hours. |
| `30_search.zshrc` | Load the shared search module after `compinit`. |
| `500_misc.zshrc` | Load the shared tool module after `compinit`. |
| `999_zsh.zshrc` | Load Zsh plugins, the fallback prompt, and Atuin. |

Keep search and tool wrappers in `zsh.d/`. Zsh must load completion before Skim, FZF, and `kubectl` completion. Load Atuin after `zsh-autosuggestions`.

### Bash

Load Bash configuration in this order:

```text
.bash_profile                         interactive login shells
  └─ source .bashrc
.bashrc                               all interactive Bash shells
  ├─ source .profile
  ├─ source .config/sh/.shrc
  └─ configure Bash history
```

Keep `.bash_profile`. Bash does not load `.bashrc` automatically for login shells.

Do not rely on `$ENV` for Bash. Bash ignores `$ENV` during normal interactive startup.

### POSIX `sh`

Load portable configuration through `.profile` and `$ENV`:

```text
.profile
  ├─ configure XDG paths
  ├─ source profile.d/*.sh
  └─ export ENV=.config/sh/.shrc
.config/sh/.shrc                      interactive shells
  └─ source sh.d/*.sh
```

Expect shell-specific differences. POSIX does not standardize history, completion, prompt hooks, or startup-file behavior beyond the base shell rules.

## Maintain shared configuration

Place portable profile settings under `.config/sh/profile.d/`:

| File | Purpose |
| --- | --- |
| `10_functions.sh` | Define `path_add`, `has`, and `source_cache`. |
| `20_env.sh` | Configure XDG application paths, editors, pagers, history capacity, and Mise shims. |

Place shared interactive behavior under `.config/sh/sh.d/`:

| File | Purpose |
| --- | --- |
| `20_aliases.sh` | Define portable aliases, including `dotfiles`. |
| `30_search.sh` | Configure Skim, FZF, Atuin, and Zoxide by shell capability. |
| `40_tools.sh` | Configure prompts, language managers, SDKMAN, AWS completion, and `kubectl` completion for Bash and Zsh. |

Keep shell-specific syntax out of portable branches. Guard Bash and Zsh integrations with `case $_shell`.

## Understand integration support

| Integration | POSIX `sh` | Bash | Zsh |
| --- | --- | --- | --- |
| Mise shims | Yes | Yes | Yes |
| `mise activate` | No | Yes | Yes |
| Skim/FZF command defaults | Yes | Yes | Yes |
| Skim/FZF completion and bindings | No | Yes | Yes |
| Atuin | No | Yes | Yes |
| Zoxide | `zoxide init posix` | Yes | Yes |
| Starship | No | Yes | Yes |
| Spaceship fallback | No | No | Yes |
| rbenv/jenv hooks | No | Yes | Yes |
| SDKMAN | No | Yes | Yes |
| AWS completion | No | Yes | No |
| `kubectl` completion | No | Yes | Yes |

Use Mise shims in every shell. Activate Mise only in Bash and Zsh; Mise does not provide an `activate sh` target.

Prefer `aws_completer` for AWS CLI v2 Bash completion:

```bash
complete -C "$(command -v aws_completer)" aws
```

Fall back to `aws_bash_completer` for older installations. Do not load Bash completion code in POSIX `sh` or Zsh.

## Keep history separate

Share only the history capacity:

```sh
HISTSIZE=20000
```

Store Bash and Zsh history in separate files:

```text
$XDG_STATE_HOME/.bash_history
$XDG_STATE_HOME/.zsh_history
```

Do not share one file. Zsh extended history uses a format that Bash does not understand.

Configure shell-specific controls in their native files:

- Configure Bash with `HISTFILESIZE`, `HISTCONTROL`, and `shopt` in `.bashrc`.
- Configure Zsh with `SAVEHIST` and `setopt` in `0_base.zshrc`.
- Do not assume history support in POSIX `sh`.

## Use Mise

Add the static shims directory in the shared profile:

```sh
$MISE_DATA_DIR/shims
```

Keep the shims before Homebrew paths so Mise-managed versions win command resolution.

Activate Mise in interactive Bash and Zsh through `.config/sh/.shrc`. Expect Mise directory and prompt hooks to add runtime cost. Retain static shims for non-interactive commands and POSIX `sh`.

## Reuse generated shell code

Call `source_cache` for tools that emit initialization scripts:

```sh
source_cache CACHE_FILE COMMAND [ARG ...]
```

Rebuild the cache when it is missing, empty, or older than the generator executable. Write updates to a temporary file, then rename the file after successful generation. Keep the previous cache when generation fails. Byte-compile generated Zsh code with `zcompile`.

Store generated files under:

```text
$XDG_CACHE_HOME/shell/
```

Remove a cache file to force regeneration:

```bash
rm "$XDG_CACHE_HOME/shell/zoxide.zsh"*
```

## Use the dotfiles alias

Run Git against the bare dotfiles repository:

```bash
dotfiles status
dotfiles add .config/sh/.shrc
dotfiles commit -m "docs(shell): update shell configuration"
```

The alias resolves to:

```bash
git --git-dir="$HOME/.local/share/dotfiles" --work-tree="$HOME"
```

## Test shell configuration

Run syntax, cache, and isolated startup tests:

```bash
mise run --cwd ~/.config/dotfiles shell:test
```

Test these behaviors:

- Validate POSIX `sh`, Bash, and Zsh syntax.
- Verify cache creation and invalidation.
- Preserve valid caches after generator failures.
- Verify Zsh byte compilation.
- Start isolated interactive `sh`, Bash, and Zsh sessions.
- Confirm that Zsh initializes `compdef`.

## Benchmark startup

Run isolated warm-start benchmarks:

```bash
mise run --cwd ~/.config/dotfiles shell:bench
```

Increase the sample count:

```bash
RUNS=50 mise run --cwd ~/.config/dotfiles shell:bench
```

Profile Zsh functions:

```bash
ZSH_PROFILE=1 zsh -lic exit
```

Compare warm results. Do not enforce performance thresholds in hosted CI; runner variance makes them unreliable.

## Reload configuration

Start a new login shell after changing startup files:

```bash
exec zsh -l
```

```bash
exec bash -l
```

Start a clean POSIX interactive shell with the configured environment:

```bash
ENV="$XDG_CONFIG_HOME/sh/.shrc" sh -i
```
