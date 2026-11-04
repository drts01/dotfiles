+++
title = "Shell files"
description = "Support levels, startup files, modules, integrations, and state paths for POSIX sh, Bash, and Zsh."
weight = 30

[extra]
type = "reference"
+++

Files and integrations of the shared shell configuration.
For the load order, see [Shell startup](@/docs/concepts/shell-startup.md).

## Support levels

| Shell      | Support  | Entry points                                             |
| ---------- | -------- | -------------------------------------------------------- |
| Zsh        | Full     | `.zshenv`, `.config/zsh/.zprofile`, `.config/zsh/.zshrc` |
| Bash       | Full     | `.bash_profile`, `.bashrc`                               |
| POSIX `sh` | Baseline | `.profile`, `$ENV` → `.config/sh/.shrc`                  |

## Profile modules

Loaded by `.profile` for login shells, in `.config/sh/profile.d/`:

| File              | Purpose                                                               |
| ----------------- | --------------------------------------------------------------------- |
| `10_functions.sh` | Set `_shell` and `LOCAL_OS`; define `path_add`, `has`, `source_cache` |
| `20_env.sh`       | Configure XDG application paths, editors, pagers, and mise shims      |

## Interactive modules

Loaded by `.config/sh/.shrc` for interactive shells, in `.config/sh/sh.d/`:

| File                  | Purpose                                                                                       |
| --------------------- | --------------------------------------------------------------------------------------------- |
| `10_interactive.sh`   | Per-shell history files, history capacity, and vi mode                                        |
| `20_aliases.sh`       | Portable aliases, including `dotfiles`                                                        |
| `30_search.sh`        | Skim, FZF, Atuin, and Zoxide by shell capability                                              |
| `40_tools.sh`         | Prompts, language managers, SDKMAN, AWS completion, and `kubectl` completion for Bash and Zsh |
| `90_prompt_osc133.sh` | Portable OSC 133 prompt markers for POSIX `sh` on supported terminals                         |

## Zsh modules

Loaded by `.config/zsh/.zshrc` in lexical order, in `.config/zsh/zsh.d/`:

| File              | Purpose                                              |
| ----------------- | ---------------------------------------------------- |
| `0_base.zshrc`    | Zsh history behavior                                 |
| `90_osc133.zshrc` | OSC 133 prompt hooks on supported terminals          |
| `999_zsh.zshrc`   | Zsh plugins, the fallback prompt, and Atuin          |

## Functions

| Function                                    | Behavior                                                       |
| ------------------------------------------- | -------------------------------------------------------------- |
| `has COMMAND`                               | Succeed when `COMMAND` is an executable on `PATH`              |
| `path_add DIR`                              | Prepend `DIR` to `PATH` unless present                         |
| `source_cache CACHE_FILE COMMAND [ARG ...]` | Cache and source the output of `COMMAND`; skip missing tools   |

## Integrations

| Integration                      | POSIX `sh`          | Bash | Zsh |
| -------------------------------- | ------------------- | ---- | --- |
| mise shims                       | Yes                 | Yes  | Yes |
| `mise activate`                  | No                  | Yes  | Yes |
| Skim/FZF command defaults        | Yes                 | Yes  | Yes |
| Skim/FZF completion and bindings | No                  | Yes  | Yes |
| Atuin                            | No                  | Yes  | Yes |
| Zoxide                           | `zoxide init posix` | Yes  | Yes |
| Starship                         | No                  | Yes  | Yes |
| Spaceship fallback               | No                  | No   | Yes |
| rbenv/jenv hooks                 | No                  | Yes  | Yes |
| SDKMAN                           | No                  | Yes  | Yes |
| AWS completion                   | No                  | Yes  | No  |
| `kubectl` completion             | No                  | Yes  | Yes |

Bash loads AWS CLI completion from `aws_completer`, or from `aws_bash_completer` on older installations.

## History

| Shell      | File                           | Shell-specific controls                                   |
| ---------- | ------------------------------ | --------------------------------------------------------- |
| POSIX `sh` | `$XDG_STATE_HOME/.sh_history`  | Only in `sh` implementations that support `HISTFILE`      |
| Bash       | `$XDG_STATE_HOME/.bash_history`| `HISTFILESIZE`, `HISTCONTROL`, `shopt` in `.bashrc`       |
| Zsh        | `$XDG_STATE_HOME/.zsh_history` | `SAVEHIST`, `setopt` in `0_base.zshrc`                    |

All shells: `HISTSIZE=20000`, set in `sh.d/10_interactive.sh`.

## Paths

| Path                       | Contents                                                |
| -------------------------- | ------------------------------------------------------- |
| `$MISE_DATA_DIR/shims`     | mise shims, first on `PATH` ahead of Homebrew           |
| `$XDG_CACHE_HOME/shell/`   | `source_cache` output; delete a file to regenerate it   |
| `$XDG_STATE_HOME/`         | History files                                           |

## Diagnostic commands

| Command                                 | Purpose                                                |
| --------------------------------------- | ------------------------------------------------------ |
| `ZSH_PROFILE=1 zsh -lic exit`           | Print Zsh startup function timings                     |
| `ENV="$XDG_CONFIG_HOME/sh/.shrc" sh -i` | Start a POSIX interactive shell with the shared config |
