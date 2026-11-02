+++
title = "Bootstrap"
updated = 2026-10-31
weight = 1
+++

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

Bootstrap is split into two scripts:

- `.config/dotfiles/bootstrap.sh` — remote entrypoint.
  Installs [mise](https://mise.jdx.dev)
  (skip with `SKIP_MISE_INSTALL=1`; failures are non-fatal), then downloads and runs the deploy script.
- `.config/dotfiles/mise-tasks/bootstrap.sh` — deploy script.
  Requires only git and a POSIX shell:
  1. Clones the bare repo to `~/.local/share/dotfiles`.
  2. Checks out tracked files into `$HOME` on first run, backing up conflicting
     pre-existing files to `~/.df-bak`; pulls (fast-forward only) on later runs.
  3. Syncs submodules.
  4. Installs git hooks via `mise run install-hooks` when mise is available;
     otherwise runs `install-hooks.sh` directly (skipped if `prek` is absent).

Deploy without mise:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | SKIP_MISE_INSTALL=1 sh
```

Deploy without curl or wget, using git as the installer:

```bash
git clone --bare --single-branch --depth=1 https://github.com/drts01/dotfiles ~/.local/share/dotfiles
sh -c "$(git --git-dir="$HOME/.local/share/dotfiles" show HEAD:.config/dotfiles/mise-tasks/bootstrap.sh)"
```

## How it works

<!-- rumdl-disable MD013 MD075 -->
{% <devlab.diagram id="bootstrap-flow" label="Bootstrap flow" description="The entrypoint optionally installs mise, then runs the git-only deploy script. The deploy script hands off to mise for git hooks only when mise is on PATH."> %}
flowchart TD
curl["curl -fsSL bootstrap.sh piped to sh"]
gitonly["git clone --bare, then git show the deploy script"]
skip{"SKIP_MISE_INSTALL set?"}
mise["Install mise, non-fatal"]
deploy["Run mise-tasks/bootstrap.sh"]
clone["Clone bare repo if missing"]
index{"Bare repo has an index?"}
checkout["Check out, back up conflicts to ~/.df-bak"]
pull["git pull --ff-only"]
subs["Sync submodules"]
hasmise{"mise on PATH?"}
hooks["mise trust, then mise run install-hooks"]
direct["install-hooks.sh, skipped without prek"]

curl --> skip
skip -->|no| mise
skip -->|yes| deploy
mise --> deploy
gitonly --> deploy
deploy --> clone
clone --> index
index -->|no| checkout
index -->|yes| pull
checkout --> subs
pull --> subs
subs --> hasmise
hasmise -->|yes| hooks
hasmise -->|no| direct
{% </devlab.diagram> %}
<!-- rumdl-enable MD013 MD075 -->

- **Idempotent:** Rerun safely; later runs only pull and sync submodules.
- **First checkout:** Keyed on `~/.local/share/dotfiles/index`, not the repo directory.
  Resumes interrupted installs and supports a manually cloned bare repo.
- **Bare repo config:** Keep `core.bare=true`; remove the legacy `core.worktree` setting on reruns.
  Work-tree commands pass `--work-tree="$HOME"` explicitly, and submodules run from `$HOME`.
- **Backups:** Tracked paths already in `$HOME` move to `~/.df-bak`.
  A later backup of the same path overwrites the earlier one.
- **Pulls:** Fast-forward only; never creates merge commits in `$HOME`.
- **Fetch refspec:** Set on the bare clone so `origin/<branch>` updates.
- **Downloads:** Saved to temp files before running; a failed fetch aborts instead of piping nothing into `sh`.
- **mise:** Optional.
  Install failures warn and continue.

### Upgrade an installation with the legacy deploy script

After this fix is published, run the remote entrypoint for the first upgrade instead of `mise run bootstrap`
or `mise run update`.
The old installed deploy script writes `core.worktree` again after it pulls;
the entrypoint fetches and runs the new script, which clears that setting and replaces the installed script:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | SKIP_MISE_INSTALL=1 sh
```

Subsequent local updates use the new installed script.
To silence the warning before the fix is published,
run `git config --file "$HOME/.local/share/dotfiles/config" --unset-all core.worktree`.
The old installed script will restore it if run again.

### Environment variables

| Variable            | Default                                                   | Purpose                               |
| ------------------- | --------------------------------------------------------- | ------------------------------------- |
| `SKIP_MISE_INSTALL` | unset                                                     | Any value skips installing mise       |
| `MISE_INSTALL_PATH` | `~/.local/bin/mise`                                       | mise binary location, added to `PATH` |
| `RAW_URL`           | `https://raw.githubusercontent.com/drts01/dotfiles/trunk` | Source of the deploy script           |
| `REPO_URL`          | `https://github.com/drts01/dotfiles`                      | Repository to clone                   |
| `DEST_DIR`          | `~/.local/share/dotfiles`                                 | Bare repository location              |

### Testing

Run the bootstrap integration test on the host (requires git, curl or wget, and network access for submodules):

```bash
mise run --cd ~/.config/dotfiles bootstrap:test
```

The test deploys into throwaway home directories with mise off `PATH` and checks:

- Fresh install through the entrypoint (curl, or wget when curl is absent), including backup of a conflicting `.bashrc`.
- Repeat run removes a legacy `core.worktree`, leaves `$HOME` unchanged, and keeps `dotfiles status --porcelain` empty.
- Upstream commits fast-forward.
- Upgrade via the remote entrypoint replaces the old installed script; later local runs do not restore `core.worktree`.
- Git-only install into a pre-cloned bare repo.

Run the same bootstrap test and ShellSpec shell specs as a non-root user in clean containers
(podman, else docker; override with `CONTAINER_ENGINE`).
Install ShellSpec with `mise --cd .config/dotfiles install shellspec` before running from a clone;
the container driver mounts the resolved mise installation read-only.
Pass image names to select containers; omit them to run all defaults:

```bash
mise run --cd ~/.config/dotfiles bootstrap:test:container
mise run --cd ~/.config/dotfiles bootstrap:test:container -- alpine:latest
mise run --cd ~/.config/dotfiles bootstrap:test:container -- cgr.dev/chainguard/git:latest-dev fedora:latest
```

| Image                               | Coverage                                                       |
| ----------------------------------- | -------------------------------------------------------------- |
| `buildpack-deps:stable-scm`         | Debian, dash `sh`, git and curl preinstalled (no apt)          |
| `alpine:latest`                     | BusyBox `sh`, curl and git installed with `apk`                |
| `fedora:latest`                     | bash `sh`, git installed with `dnf`                            |
| `cgr.dev/chainguard/git:latest-dev` | Wolfi, dash `sh`, git and GNU wget only (entrypoint wget path) |

`tests/bootstrap-container.sh` starts each image as root with a `/bin/sh` entrypoint
and mounts the checkout read-only at `/src` and the host ShellSpec installation at `/opt/shellspec`.
`tests/bootstrap-container-setup.sh` installs missing tools, creates the `tester` user, then runs bootstrap,
POSIX unit specs, and POSIX startup specs as that user.
The POSIX startup specs check each image's `/bin/sh` login profile and interactive `$ENV` startup;
unit specs check shared functions and cache behavior.
Set `TEST_BASH=required` to fail if Bash is absent, `TEST_BASH=skip` to omit Bash,
or leave it unset (`auto`) to run Bash unit and startup specs when Bash is present.
CI requires Bash on Debian, Fedora, and Chainguard, and skips it on Alpine.

Network overrides:

- Set `ALPINE_MIRROR` (e.g. `https://mirrors.edge.kernel.org/alpine`) on networks that block `dl-cdn.alpinelinux.org`.
- Use `docker.io/chainguard/git:latest-dev` (same digest) on networks that block `cgr.dev` blob storage.

CI runs one parallel bootstrap job per image and the host bootstrap test on Ubuntu and macOS.
On both hosts it runs `spec/unit` under `sh`, `bash`, and `zsh`, plus `spec/startup` once;
failed ShellSpec jobs upload JUnit reports.
Run `mise run --cd ~/.config/dotfiles shell:test:posix` to test the host's `/bin/sh` separately,
or `mise run --cd ~/.config/dotfiles shell:test:bash` to test Bash.

## mise tasks

Tasks live in `.config/dotfiles/mise.toml` and `.config/dotfiles/mise-tasks/`,
so they're re-runnable independently of the curl install:

| Task                       | Description                                                                          |
| -------------------------- | ------------------------------------------------------------------------------------ |
| `bootstrap`                | Check out or pull dotfiles, sync submodules, and install [git hooks](#install-hooks) |
| `update`                   | Run `bootstrap`, then `mise bootstrap` from the global config (`~/.config/mise`)     |
| `install-hooks`            | Install [`prek`](#prek) git hooks patched for the bare repo                          |
| `doctor`                   | Verify required tools, the bare repo, and git hooks are correctly installed          |
| `bootstrap:test`           | Test bootstrap in throwaway home directories without mise, including a repeat run    |
| `bootstrap:test:container` | Run `bootstrap:test` as non-root in containers; pass images to select                |

Run any task from an installed dotfiles home with:

```bash
mise run --cd ~/.config/dotfiles <task>
```

To run tasks from a clone of this repository,
see [CONTRIBUTING.md](https://github.com/drts01/dotfiles/blob/trunk/.github/CONTRIBUTING.md#run-tasks).

### `prek`

Installed via `[tools] prek` in `.config/dotfiles/mise.toml`; `mise.lock` pins the resolved version.

### `install-hooks`

Runs `prek install` against `.config/dotfiles/prek.toml` and patches the generated pre-commit hook
so it targets the bare repo's `GIT_DIR`/ `GIT_WORK_TREE` instead of a normal working copy.
See [Git hooks](/docs/prek/).

## Verifying an install

```bash
mise run --cd ~/.config/dotfiles doctor
```

Checks that `git`, `mise`, `uv`, and `prek` are on `PATH`, the bare repo exists, `dotfiles status` runs clean,
and the pre-commit hook is installed and executable.
