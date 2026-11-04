+++
title = "Shell environments"
description = "Load and maintain shared POSIX sh, Bash, and Zsh configuration."
weight = 3
+++

Share one set of aliases, environment variables, and tool integrations across POSIX `sh`, Bash, and Zsh.

## Choose a shell

Use the configuration at these support levels:

| Shell      | Support  | Entry points                                             |
| ---------- | -------- | -------------------------------------------------------- |
| Zsh        | Full     | `.zshenv`, `.config/zsh/.zprofile`, `.config/zsh/.zshrc` |
| Bash       | Full     | `.bash_profile`, `.bashrc`                               |
| POSIX `sh` | Baseline | `.profile`, `$ENV` → `.config/sh/.shrc`                  |

Use Zsh or Bash for completion, prompt, Atuin, SDKMAN, and language-manager hooks.
Use POSIX `sh` for portable aliases, environment variables, mise shims, search defaults, and Zoxide.

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
| `20_env.sh`       | Configure XDG application paths, editors, pagers, and mise shims.                   |

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

mise has no `activate sh` target, so POSIX `sh` uses shims only.
Bash loads AWS CLI completion from `aws_completer`, or from `aws_bash_completer` on older installations.

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

## Use mise

mise is optional; without it, the shims entry resolves nothing.
The shared profile adds the static shims directory to `PATH`:

```sh
$MISE_DATA_DIR/shims
```

Keep the shims before Homebrew paths so mise-managed versions win command resolution.

Activate mise in interactive Bash and Zsh through `.config/sh/.shrc`.
Expect mise directory and prompt hooks to add runtime cost.
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

Verify that the shared configuration loaded:

```bash
alias dotfiles
```

## Test shell configuration

This section and the next are for contributors.
They require a development clone set up with `sh .config/dotfiles/dev-setup.sh`, which requires mise;
see [Contributing](https://github.com/drts01/dotfiles/blob/trunk/.github/CONTRIBUTING.md#run-tasks).

Run the [ShellSpec](https://shellspec.info/) suite from the clone root:

```bash
mise run shell:test
```

Run one shell's unit specs and startup checks:

```bash
mise run shell:test:posix
mise run shell:test:bash
mise run shell:test:zsh
```

Smoke-test the pinned mise tools in isolated `sh`, Bash, and Zsh startup:

```bash
mise run shell:test:tools
```

The specs verify cache creation, invalidation, failure recovery, Zsh byte compilation, aliases, `PATH`, history,
and completion and plugin startup.
Add tests in the matching directory:

- `spec/unit/`: reusable functions and caches; runs under `sh`, Bash, and Zsh.
- `spec/startup/`: subprocess syntax and startup against the real `/bin/sh`, Bash, and Zsh entry points.
- `tests/bootstrap*.sh`: bootstrap integration; see [Test the installer](@/docs/bootstrap.md#test-the-installer).

Write JUnit reports with `shellspec --output junit`.

## Benchmark startup

Run isolated warm-start benchmarks; add `RUNS` to change the sample count:

```bash
mise run shell:bench
RUNS=50 mise run shell:bench
```

Export sanitized samples and metadata (requires Python 3):

```bash
BENCH_JSON=./shell-profile/results.json BENCH_METADATA=./shell-profile/metadata.json \
  mise run shell:bench
```

The benchmark runs each shell in a throwaway home with `PATH=/usr/bin:/bin`, so it excludes mise-installed tools.
Profile Zsh functions separately:

```bash
ZSH_PROFILE=1 zsh -lic exit
```

### Compare a change in CI

Dispatch the [Shell startup comparison](https://github.com/drts01/dotfiles/actions/workflows/shell-compare.yaml)
workflow from `trunk` with the full commit SHA of a candidate.
On each Linux and macOS runner, it measures `trunk`, the candidate, the candidate, then `trunk`,
using the `trunk` harness for both.
Read paired medians in the job summary; download the `shell-compare-*` artifacts for raw exports.
Compare revisions from the same run; use historical baselines for triage only.

### Read the history

The [Shell profile history](https://github.com/drts01/dotfiles/actions/workflows/shell-profile.yaml) workflow records
`trunk` after relevant pushes.
Dispatch it from `trunk` after a runner-image upgrade.
It enforces no performance threshold; hosted runner variance makes thresholds unreliable.

- The chart job summary links the `shell-profile-trends` artifact: one SVG chart per shell and runner,
  plotting per-run median and within-run standard deviation for comparable runs only.
- Artifacts expire after up to 90 days.
  Durable per-run JSON lives on the [`benchmarks` branch](https://github.com/drts01/dotfiles/tree/benchmarks/results).
- Treat a runner-image upgrade as a new baseline.

Read and chart the durable history:

```bash
git clone --branch benchmarks https://github.com/drts01/dotfiles.git shell-profile-history
python3 ~/.config/dotfiles/bench/profile-data.py read shell-profile-history
python3 ~/.config/dotfiles/bench/profile-data.py chart shell-profile-history ./shell-profile-charts 123456789 1
```

Replace `123456789 1` with the run ID and attempt from an existing `results/<os>-<arch>/<run-id>-<attempt>.meta.json`;
the run must include Linux and macOS measurements.

The archive job needs Actions write permission to `benchmarks` and branch rules that allow bot pushes.
If policy blocks it, keep the artifacts or use an approved external archive.
Keep one file per run and attempt; never rewrite old results.
