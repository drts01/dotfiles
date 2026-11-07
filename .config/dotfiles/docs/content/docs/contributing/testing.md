+++
title = "Test the dotfiles"
description = "Run the installer, shell, and container tests, and benchmark shell startup."
weight = 20

[extra]
type = "how-to"
+++

Run the test that matches your change from the root of a [development clone](@/docs/contributing/development.md).

## Test the installer

The host test needs network access for submodules:

```bash
mise run bootstrap:test
```

It deploys into throwaway home directories with mise off `PATH` and checks:

- A fresh install through the entrypoint, including backup of a conflicting `.bashrc` into a private directory.
- A repeat run removes a legacy `core.worktree`, leaves `$HOME` unchanged,
  and keeps `dotfiles status --porcelain` empty.
- Upstream commits fast-forward.
- An upgrade through the remote entrypoint replaces the old installed script;
  later local runs do not restore `core.worktree`.
- Commit pinning: a pinned fresh install, a return to the default branch,
  and rejection of unknown commits and of pins older than the installation.
- A Git-only install into a pre-cloned bare repository.
- Submodule selection, offline: tool detection, exclusions, explicit groups,
  and Neovim startup without plugins when Neovim is available.

Test the doctor in isolation:

```bash
sh .config/dotfiles/tests/doctor.sh
```

## Test in containers

Run the installer test and the POSIX ShellSpec specs as a non-root user in clean containers.
Pass image names to select containers, or omit them to run every default image:

```bash
mise run bootstrap:test:container
mise run bootstrap:test:container -- alpine:latest
mise run bootstrap:test:container -- cgr.dev/chainguard/git:latest-dev fedora:latest
```

The default images are listed in [Platform support](@/docs/reference/support.md#installer).

| Variable           | Default                 | Purpose                                                             |
| ------------------ | ----------------------- | ------------------------------------------------------------------- |
| `CONTAINER_ENGINE` | `podman`, else `docker` | Container engine                                                    |
| `TEST_BASH`        | `auto`                  | `required` fails without Bash; `skip` omits Bash specs              |
| `ALPINE_MIRROR`    | unset                   | Alpine mirror, for example `https://mirrors.edge.kernel.org/alpine` |

When `cgr.dev` blob storage is blocked, use `docker.io/chainguard/git:latest-dev`, the same digest.

How the driver works:

- The task installs the locked ShellSpec and mounts it read-only at `/opt/shellspec`;
  `sh .config/dotfiles/tests/bootstrap-container.sh` does the same.
- `tests/bootstrap-container.sh` starts each image as root with a `/bin/sh` entrypoint
  and mounts the checkout read-only at `/src`.
- `tests/bootstrap-container-setup.sh` installs missing tools, creates the `tester` user, then runs the installer test,
  POSIX unit specs, and POSIX startup specs as that user.

## Test the shell configuration

Run the [ShellSpec](https://shellspec.info/) suite:

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

Add tests in the matching directory:

| Directory             | Scope                                                                     |
| --------------------- | ------------------------------------------------------------------------- |
| `spec/unit/`          | Reusable functions and caches; runs under `sh`, Bash, and Zsh             |
| `spec/startup/`       | Syntax and startup against the real `/bin/sh`, Bash, and Zsh entry points |
| `tests/bootstrap*.sh` | Installer integration                                                     |

Write JUnit reports with `shellspec --output junit`.

## Benchmark startup

Run isolated warm-start benchmarks; set `RUNS` to change the sample count:

```bash
mise run shell:bench
RUNS=50 mise run shell:bench
```

Export sanitized samples and metadata; requires Python 3:

```bash
BENCH_JSON=./shell-profile/results.json BENCH_METADATA=./shell-profile/metadata.json \
  mise run shell:bench
```

The benchmark runs each shell in a throwaway home with `PATH=/usr/bin:/bin`, so it excludes mise-installed tools.

### Compare a change in CI

1. Dispatch the [Shell startup comparison](https://github.com/drts01/dotfiles/actions/workflows/shell-compare.yaml)
   workflow from `trunk` with the full commit SHA of a candidate.
2. Read paired medians in the job summary; download the `shell-compare-*` artifacts for raw exports.

Each Linux and macOS runner measures `trunk`, the candidate, the candidate, then `trunk`,
with the `trunk` harness for both.
Compare revisions from the same run; use historical baselines for triage only.

### Read the history

The [Shell profile history](https://github.com/drts01/dotfiles/actions/workflows/shell-profile.yaml) workflow records
`trunk` after relevant pushes.
Dispatch it from `trunk` after a runner-image upgrade, and treat the upgrade as a new baseline.
It enforces no performance threshold; hosted runner variance makes thresholds unreliable.

- The chart job summary links the `shell-profile-trends` artifact: one SVG chart per shell and runner.
- Artifacts expire after up to 90 days.
  Durable per-run JSON lives on the [`benchmarks` branch](https://github.com/drts01/dotfiles/tree/benchmarks/results).

Read and chart the durable history:

```bash
git clone --branch benchmarks https://github.com/drts01/dotfiles.git shell-profile-history
python3 .config/dotfiles/bench/profile-data.py read shell-profile-history
python3 .config/dotfiles/bench/profile-data.py chart shell-profile-history ./shell-profile-charts 123456789 1
```

Replace `123456789 1` with the run ID and attempt from an existing `results/<os>-<arch>/<run-id>-<attempt>.meta.json`;
the run must include Linux and macOS measurements.

The archive job needs Actions write permission to `benchmarks` and branch rules that allow bot pushes.
If policy blocks it, keep the artifacts or use an approved external archive.

## CI coverage

CI runs one installer job per container image, plus the host installer test on Ubuntu and macOS.
On both hosts, it runs `spec/unit` under `sh`, `bash`, and `zsh`, and `spec/startup` once.
Failed ShellSpec jobs upload JUnit reports.
