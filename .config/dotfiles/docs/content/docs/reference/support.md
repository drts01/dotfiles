+++
title = "Platform support"
description = "Requirements, and the operating systems and shells that CI tests."
weight = 50

[extra]
type = "reference"
+++

Requirements to use the dotfiles, and the platforms tested on every push.
For development requirements, see [Contributing](@/docs/contributing/development.md).

## Requirements

| Component    | Status   | Used for                                     |
| ------------ | -------- | -------------------------------------------- |
| Git          | Required | Install, update, and the `dotfiles` alias    |
| POSIX `sh`   | Required | Installer, deploy script, doctor, startup    |
| curl         | Optional | One-line installer; fetching mise            |
| wget         | Optional | Fetching mise when curl is missing           |
| mise         | Optional | Tasks, pinned tools, hook installation       |
| `prek`       | Optional | Pre-commit hook                              |

## Installer

CI installs the dotfiles as a non-root user on each platform.

| Platform                     | `/bin/sh`         | Downloader | Bash specs in container |
| ---------------------------- | ----------------- | ---------- | ----------------------- |
| Ubuntu, GitHub-hosted runner | dash              | curl       | n/a                     |
| macOS, GitHub-hosted runner  | Bash (POSIX mode) | curl       | n/a                     |
| Debian (`buildpack-deps`)    | dash              | curl       | Required                |
| Alpine                       | BusyBox `sh`      | curl       | Skipped                 |
| Fedora                       | Bash              | curl       | Required                |
| Wolfi (`chainguard/git`)     | dash              | wget only  | Required                |

## Shell configuration

| Test            | Platforms                    | Shells                              |
| --------------- | ---------------------------- | ----------------------------------- |
| Unit specs      | Ubuntu, macOS                | POSIX `sh`, Bash, Zsh               |
| Startup specs   | Ubuntu, macOS                | `/bin/sh` login and `$ENV` startup  |
| Container specs | Installer images             | POSIX `sh`; Bash where marked above |
| mise tool smoke | Ubuntu 24.04, macOS 15 arm64 | `sh`, Bash, Zsh with pinned tools   |

Workflow: [`.github/workflows/ci.yaml`](https://github.com/drts01/dotfiles/blob/trunk/.github/workflows/ci.yaml).
