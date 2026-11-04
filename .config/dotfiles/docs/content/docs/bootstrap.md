+++
title = "Bootstrap"
weight = 1
+++

## Install

Deploy the dotfiles into your home directory with Git and a POSIX shell.
Using the one-line command requires curl to fetch the entrypoint; the installer requires curl or wget to fetch mise.
Mise is optional: use [git alone](#install-with-git-only) if no downloader is available.

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | sh
```

The entrypoint, `.config/dotfiles/bootstrap.sh`:

1. Fetches the repository with git and resolves the commit to install.
   Nothing in `$HOME` changes if this fails.
2. Tries to install optional [mise](https://mise.jdx.dev) with curl or wget unless `DOTFILES_SKIP_MISE_INSTALL` is set.
   Without a downloader, or if the install fails, it warns and continues.
3. Runs the deploy script, `.config/dotfiles/mise-tasks/bootstrap.sh`, from that same commit:
   1. Clones the bare repo to `~/.local/share/dotfiles`.
   2. Checks out tracked files into `$HOME`, moving conflicting files to the private `~/.df-bak` directory;
      later runs fast-forward instead.
   3. Initializes plugin submodules for tools on `PATH`.
   4. Installs git hooks when `prek` is available.
4. Verifies that `~/.local/share/dotfiles` is at the resolved commit.

Rerun the command at any time to update.

### Review before running

Download the entrypoint, read it, then run it pinned to the commit you reviewed:

```bash
curl -fsSLo dotfiles-bootstrap.sh https://raw.githubusercontent.com/drts01/dotfiles/<commit>/.config/dotfiles/bootstrap.sh
less dotfiles-bootstrap.sh
DOTFILES_REF=<commit> sh dotfiles-bootstrap.sh
```

`DOTFILES_REF` accepts a branch, a tag, or a full commit ID.
Git verifies a full commit ID: every deployed file, including the deploy script, is addressed by that ID.
Later runs without `DOTFILES_REF` follow the default branch again.

- A pin older than the installed commit fails and leaves the checkout unchanged.
- A pin must include pinning support in its deploy script.
  Older commits deploy the default branch instead,
  and the installer then fails rather than report an unverified install.
- The mise installer, `https://mise.run`, is outside this verification.
  Set `DOTFILES_SKIP_MISE_INSTALL=1` to skip it.

### Choose plugin groups

Set `DOTFILES_SUBMODULES` to `auto` (default), `all`, `none`, or a comma-separated list such as `zsh,nvim`:

| Group  | Required tool     | Submodules                            | Selected by       |
| ------ | ----------------- | ------------------------------------- | ----------------- |
| `zsh`  | `zsh`             | Zsh plugins and prompt                | `auto`, `all`     |
| `nvim` | `nvim`            | Legacy Neovim plugins                 | `auto`, `all`     |
| `lua`  | `lua` or `luajit` | `z.lua`                               | `auto`, `all`     |
| `docs` | `zola`            | Theme for building this documentation | `all`, explicitly |

Helix needs no submodules.
Every selection still requires the matching tool.
Unknown group names fail before checkout.
Exclude groups with `DOTFILES_SKIP_SUBMODULES=nvim,lua`, or everything with `DOTFILES_SKIP_SUBMODULES=all`.
Set either variable on the `sh` that reads the pipe:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SKIP_SUBMODULES=nvim sh
```

Zsh and Neovim start without their plugins, but plugin-dependent features remain unavailable.
To install a skipped group later, first install its tool; for example, with `nvim` on `PATH`, run:

```bash
DOTFILES_SUBMODULES=nvim sh ~/.config/dotfiles/mise-tasks/bootstrap.sh
```

Selection and exclusion apply to each run, including `mise run --cd ~/.config/dotfiles update`;
future runs without either variable detect tools again.
Skipping does not remove already initialized plugins.

The `docs` group exists only to build this site from an installed `$HOME`.
In a development clone, `mise run docs:build` initializes the theme itself;
see [Contributing](https://github.com/drts01/dotfiles/blob/trunk/.github/CONTRIBUTING.md).

### Skip mise

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SKIP_MISE_INSTALL=1 sh
```

### Install with git only

Without curl or wget, run the deploy script straight from the cloned bare repo:

```bash
git clone --bare --single-branch --depth=1 https://github.com/drts01/dotfiles ~/.local/share/dotfiles
sh -c "$(git --git-dir="$HOME/.local/share/dotfiles" show HEAD:.config/dotfiles/mise-tasks/bootstrap.sh)"
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

- **Idempotent:** Rerun safely; later runs pull and initialize the selected submodules.
- **First checkout:** Keyed on `~/.local/share/dotfiles/index`, not the repo directory.
  Resumes interrupted installs and supports a manually cloned bare repo.
- **Bare repo config:** Keep `core.bare=true`; remove the legacy `core.worktree` setting on reruns.
  Work-tree commands pass `--work-tree="$HOME"` explicitly, and submodules run from `$HOME`.
- **Backups:** Tracked paths already in `$HOME` move to `~/.df-bak`, created with mode `700`.
  A later backup of the same path overwrites the earlier one.
- **Pulls:** Fast-forward only; never creates merge commits in `$HOME`.
  Entrypoint runs fast-forward to the resolved commit; local `update` runs pull the tracked branch.
- **Fetch refspec:** Set on the bare clone so `origin/<branch>` updates.
- **Same-commit execution:** The entrypoint never downloads the deploy script separately.
  It runs the script from the git-fetched commit, and both scripts check the installed `HEAD` against that commit.
- **Downloads:** The mise installer is saved to a temp file before running, over HTTPS and TLS 1.2 or later with curl;
  a failed fetch aborts instead of piping nothing into `sh`.
- **mise:** Optional.
  The installer needs curl or wget to fetch mise, not to deploy the dotfiles.
  Without either downloader, or if installation fails, it warns and continues.

### Upgrade an installation with the legacy deploy script

After this fix is published, run the remote entrypoint for the first upgrade instead of `mise run bootstrap`
or `mise run update`.
The old installed deploy script writes `core.worktree` again after it pulls;
the entrypoint fetches and runs the new script, which clears that setting and replaces the installed script:

```bash
curl -fsSL https://raw.githubusercontent.com/drts01/dotfiles/trunk/.config/dotfiles/bootstrap.sh | DOTFILES_SKIP_MISE_INSTALL=1 sh
```

Subsequent local updates use the new installed script.
To silence the warning before the fix is published,
run `git config --file "$HOME/.local/share/dotfiles/config" --unset-all core.worktree`.
The old installed script will restore it if run again.

### Environment variables

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

### Testing

In a development clone, first run `sh .config/dotfiles/dev-setup.sh`
(see [Contributing](https://github.com/drts01/dotfiles/blob/trunk/.github/CONTRIBUTING.md)).
Then run the bootstrap integration test from the clone root (requires git and network access for submodules):

```bash
mise run bootstrap:test
```

The test deploys into throwaway home directories with mise off `PATH` and checks:

- Fresh install through the entrypoint, including backup of a conflicting `.bashrc` into a private directory.
- Repeat run removes a legacy `core.worktree`, leaves `$HOME` unchanged, and keeps `dotfiles status --porcelain` empty.
- Upstream commits fast-forward.
- Upgrade via the remote entrypoint replaces the old installed script; later local runs do not restore `core.worktree`.
- Commit pinning: a pinned fresh install, a return to the default branch,
  and rejection of unknown commits and of pins older than the installation.
- Git-only install into a pre-cloned bare repo.
- An offline submodule selection test covers tool detection, exclusions, explicit groups,
  and Neovim startup without plugins (when Neovim is available).

Run the same bootstrap test and ShellSpec shell specs as a non-root user in clean containers
(podman, else docker; override with `CONTAINER_ENGINE`).
The container test task installs locked ShellSpec on demand;
the container driver mounts that mise installation read-only.
Running `sh .config/dotfiles/tests/bootstrap-container.sh` directly also installs it on demand.
Pass image names to select containers; omit them to run all defaults:

```bash
mise run bootstrap:test:container
mise run bootstrap:test:container -- alpine:latest
mise run bootstrap:test:container -- cgr.dev/chainguard/git:latest-dev fedora:latest
```

| Image                               | Coverage                                                       |
| ----------------------------------- | -------------------------------------------------------------- |
| `buildpack-deps:stable-scm`         | Debian, dash `sh`, git and curl preinstalled (no apt)          |
| `alpine:latest`                     | BusyBox `sh`, curl and git installed with `apk`                |
| `fedora:latest`                     | bash `sh`, git installed with `dnf`                            |
| `cgr.dev/chainguard/git:latest-dev` | Wolfi, dash `sh`, git and GNU wget only (no curl)              |

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
Run `mise run shell:test:posix` to test the host's `/bin/sh` separately,
or `mise run shell:test:bash` to test Bash from a development clone.

## mise tasks

Deployment tasks live in `.config/dotfiles/mise.toml` and `.config/dotfiles/mise-tasks/`;
development tasks live in `.config/dotfiles/dev-tasks.toml`, included by an ignored, clone-local `mise.local.toml`.
Development setup copies tracked `dev-miserc.toml`
and `dev-mise-local.toml` templates from `.config/dotfiles/` to the clone root;
the installed dotfiles never receive these root configs.
The clone's ignored `mise.local.lock` links to the tracked `.config/dotfiles/mise.lock`;
both environments resolve locked tool versions from that file.
Deployment installs only prek by default.
They are re-runnable independently of the curl install:

| Task                       | Description                                                                                         |
| -------------------------- | --------------------------------------------------------------------------------------------------- |
| `bootstrap`                | Check out or pull dotfiles, initialize selected submodules, and install [git hooks](#install-hooks) |
| `update`                   | Pull dotfiles, initialize selected submodules, and install hooks                                    |
| `install-hooks`            | Install [`prek`](#prek) git hooks patched for the bare repo                                         |
| `doctor`                   | Check the bare repo, tracked changes, and optional tools and hooks                                  |
| `bootstrap:test`           | Test bootstrap, repeat runs, and submodule selection in throwaway homes without mise                |
| `bootstrap:test:container` | Run `bootstrap:test` as non-root in containers; pass images to select                               |

Run any task from an installed dotfiles home with:

```bash
mise run --cd ~/.config/dotfiles <deployment-task>
# From the root of a development clone after running dev-setup.sh:
mise run <development-task>
```

Run `mise --cd ~/.config/mise bootstrap` separately to update the machine toolchain.

To run tasks from a clone of this repository,
see [CONTRIBUTING.md](https://github.com/drts01/dotfiles/blob/trunk/.github/CONTRIBUTING.md#run-tasks).

### `prek`

Installed via `[tools] prek` in `.config/dotfiles/mise.toml`;
the shared `mise.lock` pins prek and the task-only development tools without enabling them for deployment.

### `install-hooks`

Runs `prek install` against `.config/dotfiles/prek.toml` and patches the generated pre-commit hook
so it targets the bare repo's `GIT_DIR`/ `GIT_WORK_TREE` instead of a normal working copy.
See [Git hooks](/docs/prek/).

## Verifying an install

Run the doctor directly, including after a git-only install:

```bash
sh ~/.config/dotfiles/mise-tasks/doctor.sh
```

Check that git and the bare repository are usable and that untracked files are hidden from its status.
Report tracked changes as a warning, not an installation failure.
Report missing mise, prek, and pre-commit hooks as optional warnings; fail for a broken installed hook.
With mise installed, `mise run --cd ~/.config/dotfiles doctor` runs the same check.
