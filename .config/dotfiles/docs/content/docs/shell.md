+++
title = "Shell environments"
description = "Load and maintain shared POSIX sh, Bash, and Zsh configuration."
updated = 2026-11-02
weight = 3
+++

## Choose a shell

Use the configuration at these support levels:

| Shell      | Support  | Entry points                                             |
| ---------- | -------- | -------------------------------------------------------- |
| Zsh        | Full     | `.zshenv`, `.config/zsh/.zprofile`, `.config/zsh/.zshrc` |
| Bash       | Full     | `.bash_profile`, `.bashrc`                               |
| POSIX `sh` | Baseline | `.profile`, `$ENV` → `.config/sh/.shrc`                  |

Use Zsh or Bash for completion, prompt, Atuin, SDKMAN, and language-manager hooks.
Use POSIX `sh` for portable aliases, environment variables, Mise shims, search defaults, and Zoxide.

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
  ├─ configure Homebrew completions and run compinit
  ├─ source $ENV → .config/sh/.shrc (all shared modules in order)
  └─ source .config/zsh/zsh.d/*.zshrc in lexical order
```

Use these Zsh modules:

| File              | Purpose                                               |
| ----------------- | ----------------------------------------------------- |
| `0_base.zshrc`    | Configure Zsh history behavior.                       |
| `90_osc133.zshrc` | Register OSC 133 prompt hooks on supported terminals. |
| `999_zsh.zshrc`   | Load Zsh plugins, the fallback prompt, and Atuin.     |

Load `compinit` in `.zshrc` before the shared search and tool modules so Skim, FZF,
and `kubectl` can register completions.
Load Atuin after `zsh-autosuggestions`.

### Bash

Load Bash configuration in this order:

```text
.bash_profile                         interactive login shells
  └─ source .bashrc
.bashrc                               all interactive Bash shells
  ├─ source .profile
  ├─ source .config/sh/.shrc
  └─ configure Bash history and OSC 133 prompt hooks
```

Keep `.bash_profile`.
Bash does not load `.bashrc` automatically for login shells.

Do not rely on `$ENV` for Bash.
Bash ignores `$ENV` during normal interactive startup.

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

Expect shell-specific differences.
POSIX does not standardize history, completion, prompt hooks, or startup-file behavior beyond the base shell rules.

## Maintain shared configuration

Place portable profile settings under `.config/sh/profile.d/`:

| File              | Purpose                                                                             |
| ----------------- | ----------------------------------------------------------------------------------- |
| `10_functions.sh` | Define `path_add`, `has`, and `source_cache`.                                       |
| `20_env.sh`       | Configure XDG application paths, editors, pagers, and Mise shims.                   |

Place shared interactive behavior under `.config/sh/sh.d/`:

| File                  | Purpose                                                                                                  |
| --------------------- | -------------------------------------------------------------------------------------------------------- |
| `10_interactive.sh`   | Set per-shell history files, history capacity, and vi mode for every interactive shell.                  |
| `20_aliases.sh`       | Define portable aliases, including `dotfiles`.                                                           |
| `30_search.sh`        | Configure Skim, FZF, Atuin, and Zoxide by shell capability.                                              |
| `40_tools.sh`         | Configure prompts, language managers, SDKMAN, AWS completion, and `kubectl` completion for Bash and Zsh. |
| `90_prompt_osc133.sh` | Configure portable OSC 133 prompt markers for POSIX `sh` on supported terminals.                         |

Keep shell-specific syntax out of portable branches.
Guard Bash and Zsh integrations with `case $_shell`.

## Understand integration support

| Integration                      | POSIX `sh`          | Bash | Zsh |
| -------------------------------- | ------------------- | ---- | --- |
| Mise shims                       | Yes                 | Yes  | Yes |
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

Use Mise shims in every shell.
Activate Mise only in Bash and Zsh; Mise does not provide an `activate sh` target.

Prefer `aws_completer` for AWS CLI v2 Bash completion:

```bash
complete -C "$(command -v aws_completer)" aws
```

Fall back to `aws_bash_completer` for older installations.
Do not load Bash completion code in POSIX `sh` or Zsh.

## Keep history separate

Set the history capacity and vi bindings in `sh.d/10_interactive.sh` for every interactive shell,
including non-login children:

```sh
HISTSIZE=20000
```

Store each shell implementation's history in a separate file:

```text
$XDG_STATE_HOME/.sh_history
$XDG_STATE_HOME/.bash_history
$XDG_STATE_HOME/.zsh_history
```

Do not share one file.
Zsh extended history uses a format that Bash does not understand.

Configure shell-specific controls in their native files:

- Configure Bash with `HISTFILESIZE`, `HISTCONTROL`, and `shopt` in `.bashrc`.
- Configure Zsh with `SAVEHIST` and `setopt` in `0_base.zshrc`.
- Allow `sh` implementations that support `HISTFILE` to use `.sh_history`; POSIX does not require history support.
- Treat macOS `/bin/sh` as Bash, which uses `.bash_history`.

## Use Mise

Add the static shims directory in the shared profile:

```sh
$MISE_DATA_DIR/shims
```

Keep the shims before Homebrew paths so Mise-managed versions win command resolution.

Activate Mise in interactive Bash and Zsh through `.config/sh/.shrc`.
Expect Mise directory and prompt hooks to add runtime cost.
Retain static shims for non-interactive commands and POSIX `sh`.

## Reuse generated shell code

Call `source_cache` for tools that emit initialization scripts:

```sh
source_cache CACHE_FILE COMMAND [ARG ...]
```

Rebuild the cache when it is missing, empty, or older than the generator executable.
Write updates to a temporary file, then rename the file after successful generation.
Keep the previous cache when generation fails.
Byte-compile generated Zsh code with `zcompile`.

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

Run the [ShellSpec](https://shellspec.info/) suite from `.config/dotfiles/`:

```bash
mise run --cd ~/.config/dotfiles shell:test
```

Run a single shell's unit specs and startup checks:

```bash
mise run --cd ~/.config/dotfiles shell:test:posix
mise run --cd ~/.config/dotfiles shell:test:bash
mise --cd ~/.config/dotfiles exec shellspec -- shellspec --shell zsh spec/unit spec/startup/zsh_spec.sh
```

Keep reusable function and cache tests in `spec/unit/`; run them under `sh`, `bash`,
and `zsh` to exercise each implementation.
Keep subprocess syntax and startup tests in `spec/startup/` so they validate the actual OS `/bin/sh`, Bash,
and Zsh entry points.
ShellSpec reports each behavior by name and writes JUnit reports with `--output junit`.
Bootstrap integration tests remain under `tests/bootstrap*.sh`.
These specs verify cache creation, invalidation, failure recovery, Zsh byte compilation, aliases, PATH, history,
and completion/plugin startup.

## Benchmark startup

Run isolated warm-start benchmarks:

```bash
mise run --cd ~/.config/dotfiles shell:bench
```

Increase the sample count:

```bash
RUNS=50 mise run --cd ~/.config/dotfiles shell:bench
```

Export sanitized samples and metadata to a chosen directory (requires Python 3):

```bash
BENCH_JSON=./shell-profile/results.json BENCH_METADATA=./shell-profile/metadata.json \
  mise run --cd ~/.config/dotfiles shell:bench
```

Check both shell exit statuses before measuring; then use `hyperfine` warmup and repeated runs.
Link checked-out Zsh plugins into a throwaway home and use `PATH=/usr/bin:/bin` inside the measured commands.
This baseline does **not** exercise mise-installed tools;
keep it separate from the pinned `shell:test:tools` smoke test.
Keep `hyperfine` in the mise task context; do not assume a host shim is active.

Run the [Shell startup comparison](https://github.com/drts01/dotfiles/actions/workflows/shell-compare.yaml) manually
**from `trunk`** with the full commit SHA of a candidate in this repository.
The read-only workflow measures `trunk`, candidate, candidate, then `trunk` on each fixed Linux/macOS runner.
It uses the trusted `trunk` benchmark harness for both checkouts and reports paired medians
and sample dispersion in the job summary; download the `shell-compare-*` artifacts for all four raw sanitized exports.
Candidate measurements are not archived on the history branch and cannot push to it.
A saved historical baseline is useful for triage, but compare revisions from the same run to assess a change.

The [Shell profile history workflow](https://github.com/drts01/dotfiles/actions/workflows/shell-profile.yaml) records
`trunk` after relevant shell or benchmark changes are pushed; dispatch it from `trunk` to refresh the baseline after a
runner-image upgrade or when no source files changed.
It is independent of the main CI jobs and has no performance threshold.
Read the history table in the chart job's GitHub summary
and use its link to download the `shell-profile-trends` artifact: four SVG charts, one per shell and runner.
Each chart plots per-run median with within-run sample standard deviation, selecting only results with matching OS,
architecture, runner-image release, shell versions, workload, and benchmark settings.
A single comparable run shows a point, not a trend.
Charts are generated from archived data rather than committed to `benchmarks`;
their artifact and the raw `shell-profile-*` artifacts expire after up to 90 days
(or the repository's lower allowed retention limit).
Browse durable per-run JSON and metadata in the
[`benchmarks` branch](https://github.com/drts01/dotfiles/tree/benchmarks/results).
The archive job requires repository Actions token write permission to that branch and branch rules allowing bot pushes.
If policy blocks it, keep the downloadable artifacts and configure an organization-approved external archive.
Retain one file per run and attempt, review branch growth periodically, and never rewrite old results.

Read per-command median and sample standard deviation, grouped by OS, architecture, runner image/version, scenario,
runner label, `hyperfine` version, sample/warmup counts, and submodule state:

```bash
git clone --branch benchmarks https://github.com/drts01/dotfiles.git shell-profile-history
python3 ~/.config/dotfiles/bench/profile-data.py read shell-profile-history
```

Regenerate charts from the durable history by passing a recorded run ID and attempt:

```bash
python3 ~/.config/dotfiles/bench/profile-data.py chart shell-profile-history ./shell-profile-charts 123456789 1
```

Replace the example ID and attempt with the filename of an existing `results/<os>-<arch>/<run-id>-<attempt>.meta.json`;
the selected run must include both Linux and macOS measurements.
Compare only like-for-like groups; treat runner-image upgrades as a new baseline.
Do not enforce performance thresholds in hosted CI; runner variance makes them unreliable.
Profile Zsh functions separately from the timed loop:

```bash
ZSH_PROFILE=1 zsh -lic exit
```

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
