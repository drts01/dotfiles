+++
title = "Bootstrap"
description = "Install, update, and verify the dotfiles with Git and a POSIX shell."
weight = 1
+++

Install the dotfiles into your home directory with one command, and rerun it to update.

## Install

Prerequisites:

- Git and a POSIX `sh`.
- curl, to fetch the one-line entrypoint.
  Without curl, [install with Git only](#install-with-git-only).
- Optional: curl or wget, so the installer can fetch mise.
  mise is optional; the dotfiles work without it.

The installer changes your home directory:

- Moves existing files that conflict with tracked files to `~/.df-bak`, created with mode `700`.
  A later backup of the same path overwrites the earlier one.
- Installs mise to `~/.local/bin/mise` if it is missing, unless you [skip mise](#skip-mise).
- Installs a pre-commit hook in the bare repository when mise or `prek` is available.

Run the entrypoint:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

### Verify the install

Run the doctor:

```bash
sh ~/.config/dotfiles/mise-tasks/doctor.sh
```

Expect `All installation checks passed.` or `Installation checks passed with warnings.` Warnings for mise, `prek`,
and the pre-commit hook report optional components.
Fix every `FAIL` line before you use the dotfiles.

Start a new login shell to load the configuration:

```bash
exec "$SHELL" -l
```

## Install options

### Review before running

Download the entrypoint, read it, then run it pinned to the commit you reviewed:

```bash
curl -fsSLo dotfiles-bootstrap.sh https://raw.githubusercontent.com/drts01/dotfiles/<commit>/.config/dotfiles/bootstrap.sh
less dotfiles-bootstrap.sh
DOTFILES_REF=<commit> sh dotfiles-bootstrap.sh
```

`DOTFILES_REF` accepts a branch, a tag, or a full commit ID.
Git verifies a full commit ID, and every deployed file, including the deploy script, comes from that commit.
Later runs without `DOTFILES_REF` follow the default branch again.

- A pin older than the installed commit fails and leaves the checkout unchanged.
- A pin to a commit without pinning support deploys the default branch,
  then fails instead of reporting an unverified install.
- The mise installer, `https://mise.run`, is outside this verification.
  Set `DOTFILES_SKIP_MISE_INSTALL=1` to skip it.

Verify that the bare repository is at the pinned commit:

```bash
git --git-dir="$HOME/.local/share/dotfiles" rev-parse HEAD
```

### Choose plugin groups

Set `DOTFILES_SUBMODULES` to `auto` (default), `all`, `none`, or a comma-separated list such as `zsh,nvim`:

| Group  | Required tool     | Submodules                            | Selected by       |
| ------ | ----------------- | ------------------------------------- | ----------------- |
| `zsh`  | `zsh`             | Zsh plugins and prompt                | `auto`, `all`     |
| `nvim` | `nvim`            | Legacy Neovim plugins                 | `auto`, `all`     |
| `lua`  | `lua` or `luajit` | `z.lua`                               | `auto`, `all`     |
| `docs` | `zola`            | Theme for building this documentation | `all`, explicitly |

Helix needs no submodules.
Every group requires its tool, even when selected explicitly.
Unknown group names fail before checkout.

Exclude groups with `DOTFILES_SKIP_SUBMODULES=nvim,lua`, or all groups with `DOTFILES_SKIP_SUBMODULES=all`.
Set either variable on the `sh` that reads the pipe:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SKIP_SUBMODULES=nvim sh
```

Zsh and Neovim start without their plugins; plugin features stay unavailable.
Both variables apply to one run only.
Later runs without them detect tools again.
Skipping a group does not remove plugins that are already initialized.

Add a skipped group later: install its tool, then run the deploy script with the group selected:

```bash
DOTFILES_SUBMODULES=nvim sh ~/.config/dotfiles/mise-tasks/bootstrap.sh
```

Verify the result from your home directory; a leading `-` marks an uninitialized submodule:

```bash
cd ~ && git --git-dir="$HOME/.local/share/dotfiles" --work-tree="$HOME" submodule status
```

### Skip mise

Install the dotfiles without downloading mise:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SKIP_MISE_INSTALL=1 sh
```

Verify with the [doctor](#verify-the-install); it reports mise as an optional warning.

### Install with Git only

Clone the bare repository, then run the deploy script from it, without curl or wget:

```bash
git clone --bare --single-branch --depth=1 https://github.com/drts01/dotfiles ~/.local/share/dotfiles
sh -c "$(git --git-dir="$HOME/.local/share/dotfiles" show HEAD:.config/dotfiles/mise-tasks/bootstrap.sh)"
```

Verify with the [doctor](#verify-the-install).

## Update

Rerun the one-line entrypoint, or run the installed deploy script:

```bash
sh ~/.config/dotfiles/mise-tasks/bootstrap.sh
```

With mise, run `mise run --cd ~/.config/dotfiles update`.
Updates fast-forward only and never create merge commits in `$HOME`.
Verify with the [doctor](#verify-the-install).

Update the machine toolchain separately:

```bash
mise --cd ~/.config/mise bootstrap
```

### Upgrade from a deploy script that sets `core.worktree`

Older deploy scripts write `core.worktree` to the bare repository after each pull, which makes Git warn.
Run the remote entrypoint once; it replaces the installed script with one that removes the setting:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SKIP_MISE_INSTALL=1 sh
```

Do not run `mise run update` for this upgrade; it runs the old installed script, which restores the setting.
Verify that this command prints nothing:

```bash
git config --file "$HOME/.local/share/dotfiles/config" --get core.worktree
```

## How it works

<!-- rumdl-disable MD013 MD075 -->
{% <devlab.diagram id="bootstrap-flow" label="Bootstrap flow" description="The entrypoint fetches and resolves a commit with git, optionally installs mise, then runs the deploy script from that commit. The deploy script hands off to mise for git hooks only when mise is on PATH."> %}
flowchart TD
curl["curl -fsSL bootstrap.sh piped to sh"]
fetch["git fetch DOTFILES_REF, resolve and verify the commit"]
gitonly["git clone --bare, then git show the deploy script"]
skip{"DOTFILES_SKIP_MISE_INSTALL set?"}
mise["Install mise, non-fatal"]
deploy["Run mise-tasks/bootstrap.sh from the fetched commit"]
clone["Clone bare repo at the commit if missing"]
index{"Bare repo has an index?"}
checkout["Check out, back up conflicts to ~/.df-bak"]
pull["Fast-forward to the commit"]
verify["Fail unless HEAD is the resolved commit"]
subs["Initialize selected submodules or skip"]
hasmise{"mise on PATH?"}
hooks["mise trust, then mise run install-hooks"]
direct["install-hooks.sh, skipped without prek"]

curl --> fetch
fetch --> skip
skip -->|no| mise
skip -->|yes| deploy
mise --> deploy
gitonly --> deploy
deploy --> clone
clone --> index
index -->|no| checkout
index -->|yes| pull
checkout --> verify
pull --> verify
verify --> subs
subs --> hasmise
hasmise -->|yes| hooks
hasmise -->|no| direct
{% </devlab.diagram> %}
<!-- rumdl-enable MD013 MD075 -->

The entrypoint, `.config/dotfiles/bootstrap.sh`:

1. Fetches the repository with Git and resolves the commit to install.
   Nothing in `$HOME` changes if this step fails.
2. Saves the mise installer to a temporary file, then runs it;
   a failed download aborts the mise step. curl is restricted to HTTPS with TLS 1.2 or later;
   wget uses its default protocol settings.
   Without curl or wget, or if the install fails, it warns and continues.
3. Runs the deploy script, `.config/dotfiles/mise-tasks/bootstrap.sh`, from the fetched commit;
   it never downloads the deploy script separately.
4. Verifies that `~/.local/share/dotfiles` is at the resolved commit.

The deploy script:

1. Clones the bare repository to `~/.local/share/dotfiles` and sets its fetch refspec, so `origin/<branch>` updates.
2. Checks out tracked files into `$HOME` on the first run; later runs fast-forward.
   The first checkout is keyed on `~/.local/share/dotfiles/index`,
   so it resumes interrupted installs and adopts a manually cloned bare repository.
3. Keeps `core.bare=true`, removes a legacy `core.worktree`, and passes `--work-tree="$HOME"` explicitly.
4. Initializes the selected submodules from `$HOME`.
5. Links the bare repository's `info/exclude` to the tracked `.config/dotfiles/gitignore`.
6. Installs Git hooks through mise when available, or directly when `prek` is on `PATH`.

Every step is idempotent; rerun the entrypoint safely at any time.

## Environment variables

| Variable                     | Default                              | Purpose                                                                   |
| ---------------------------- | ------------------------------------ | ------------------------------------------------------------------------- |
| `DOTFILES_REF`               | default branch                       | Entrypoint: branch, tag, or full commit ID to install                     |
| `DOTFILES_SKIP_MISE_INSTALL` | unset                                | Any value skips installing mise                                           |
| `MISE_INSTALL_PATH`          | `~/.local/bin/mise`                  | mise binary location, added to `PATH`                                     |
| `REPO_URL`                   | `https://github.com/drts01/dotfiles` | Repository to fetch and clone                                             |
| `DEST_DIR`                   | `~/.local/share/dotfiles`            | Bare repository location                                                  |
| `DOTFILES_SUBMODULES`        | `auto`                               | `auto` (runtime groups), `all` (adds `docs`), `none`, or a list of groups |
| `DOTFILES_SKIP_SUBMODULES`   | unset                                | `all` or comma-separated `zsh,nvim,lua,docs` exclusions                   |
| `DOTFILES_COMMIT`            | set by the entrypoint                | Deploy script: full commit ID to deploy and verify                        |
| `DOTFILES_BRANCH`            | remote default branch                | Deploy script: branch that a pinned fresh install tracks                  |

## Tasks

Deployment tasks live in `.config/dotfiles/mise.toml` and `.config/dotfiles/mise-tasks/`.
Without mise, run `bootstrap.sh` and `doctor.sh` with `sh`,
as shown in [Update](#update) and [Verify the install](#verify-the-install).
Run a task with mise from any directory:

```bash
mise run --cd ~/.config/dotfiles <task>
```

| Task            | Description                                                                       |
| --------------- | --------------------------------------------------------------------------------- |
| `bootstrap`     | Check out or pull the dotfiles, initialize selected submodules, and install hooks |
| `update`        | Same as `bootstrap`; use it after the first install                               |
| `install-hooks` | Install [`prek` Git hooks](@/docs/prek.md) patched for the bare repository        |
| `doctor`        | Check the bare repository, tracked changes, and optional tools and hooks          |
| `docs:lint`     | Check documentation prose against the house style; used by the `vale` hook        |

Deployment installs only `prek`; tools for `docs:lint` install on first use.
Both are pinned in the shared `.config/dotfiles/mise.lock`.

## Test the installer

This section is for contributors.
It requires a development clone set up with `sh .config/dotfiles/dev-setup.sh`, which requires mise;
see [Contributing](https://github.com/drts01/dotfiles/blob/trunk/.github/CONTRIBUTING.md#run-tasks).

Development tasks live in `.config/dotfiles/dev-tasks.toml`, included by the clone's ignored `mise.local.toml`.
Development setup copies the `dev-miserc.toml` and `dev-mise-local.toml` templates to the clone root
and links the ignored `mise.local.lock` to the tracked `.config/dotfiles/mise.lock`.
Installed dotfiles never receive these files.

### Run the host test

Run the bootstrap integration test from the clone root; it needs network access for submodules:

```bash
mise run bootstrap:test
```

The test deploys into throwaway home directories with mise off `PATH` and checks:

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

### Run the container tests

Run the bootstrap test and the POSIX ShellSpec specs as a non-root user in clean containers.
The driver uses podman, else docker; override it with `CONTAINER_ENGINE`.
Pass image names to select containers, or omit them to run all defaults:

```bash
mise run bootstrap:test:container
mise run bootstrap:test:container -- alpine:latest
mise run bootstrap:test:container -- cgr.dev/chainguard/git:latest-dev fedora:latest
```

| Image                               | Coverage                                              |
| ----------------------------------- | ----------------------------------------------------- |
| `buildpack-deps:stable-scm`         | Debian, dash `sh`, Git and curl preinstalled (no apt) |
| `alpine:latest`                     | BusyBox `sh`, curl and Git installed with `apk`       |
| `fedora:latest`                     | Bash `sh`, Git installed with `dnf`                   |
| `cgr.dev/chainguard/git:latest-dev` | Wolfi, dash `sh`, Git and GNU wget only (no curl)     |

Control Bash coverage with `TEST_BASH`: `required` fails without Bash, `skip` omits it,
and `auto` (default) runs Bash specs when Bash is present.
CI requires Bash on Debian, Fedora, and Chainguard, and skips it on Alpine.

Work around blocked registries:

- Set `ALPINE_MIRROR`, for example `https://mirrors.edge.kernel.org/alpine`, when `dl-cdn.alpinelinux.org` is blocked.
- Use `docker.io/chainguard/git:latest-dev`, the same digest, when `cgr.dev` blob storage is blocked.

How the driver works:

- The task installs the locked ShellSpec on demand and mounts it read-only at `/opt/shellspec`;
  `sh .config/dotfiles/tests/bootstrap-container.sh` does the same.
- `tests/bootstrap-container.sh` starts each image as root with a `/bin/sh` entrypoint
  and mounts the checkout read-only at `/src`.
- `tests/bootstrap-container-setup.sh` installs missing tools, creates the `tester` user,
  then runs bootstrap, POSIX unit specs, and POSIX startup specs as that user.
- Startup specs check each image's `/bin/sh` login profile and interactive `$ENV` startup;
  unit specs check shared functions and cache behavior.

CI runs one bootstrap job per image, plus the host bootstrap test on Ubuntu and macOS.
On both hosts, it runs `spec/unit` under `sh`, `bash`, and `zsh`, and `spec/startup` once.
Failed ShellSpec jobs upload JUnit reports.
For shell specs on the host, see [Shell environments](@/docs/shell.md#test-shell-configuration).
