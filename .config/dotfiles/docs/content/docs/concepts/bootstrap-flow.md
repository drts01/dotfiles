+++
title = "How the installer works"
description = "The entrypoint, the deploy script, and the guarantees that make every run safe to repeat."
weight = 20

[extra]
type = "explanation"
+++

The installer has two parts: an entrypoint that fetches and verifies a commit,
and a deploy script from that same commit that changes `$HOME`.

## Flow

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
hooks["mise trust, then mise run install:git-hooks"]
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

## Entrypoint

`.config/dotfiles/bootstrap.sh`:

1. Fetches the repository with Git and resolves the commit to install.
   Nothing in `$HOME` changes if this step fails.
2. Saves the mise installer to a temporary file, then runs it;
   a failed download aborts only the mise step. curl is restricted to HTTPS with TLS 1.2 or later;
   wget uses its default protocol settings.
   Without curl or wget, or if the install fails, it warns and continues.
3. Runs the deploy script from the fetched commit; it never downloads the deploy script separately.
4. Verifies that `~/.local/share/dotfiles` is at the resolved commit.

The script body runs inside one function, so `curl | sh` never executes a partial download.

## Deploy script

`.config/dotfiles/mise-tasks/bootstrap.sh`:

1. Clones the bare repository to `~/.local/share/dotfiles` and sets its fetch refspec, so `origin/<branch>` updates.
2. Checks out tracked files into `$HOME` on the first run; later runs fast-forward.
   The first checkout is keyed on `~/.local/share/dotfiles/index`,
   so it resumes interrupted installs and adopts a manually cloned bare repository.
3. Keeps `core.bare=true`, removes a legacy `core.worktree`, and passes `--work-tree="$HOME"` explicitly.
4. Initializes the selected submodules from `$HOME`.
5. Links the bare repository's `info/exclude` to the tracked `.config/dotfiles/gitignore`.
6. Installs Git hooks through mise when available, or directly when `prek` is on `PATH`.

## Design choices

- **One commit, one source.**
  The deploy script and the files it deploys come from the same commit.
  A full commit ID in `DOTFILES_REF` makes Git verify every fetched object.
- **Verify before changing.**
  The commit resolves in a temporary directory before `$HOME` changes.
- **mise is optional.**
  A missing downloader or a failed mise install warns and continues.
  The mise installer is outside commit verification; see [Security model](@/docs/concepts/security.md).
- **Fast-forward only.**
  Updates never create merge commits in `$HOME`; diverged history stops the update.
- **Private backups.**
  Replaced files can hold credentials, so `~/.df-bak` is created with mode `700`.
- **Tool detection.**
  Plugin groups initialize only when their tool is on `PATH`;
  the documentation theme is opt-in because only a site build needs it.
- **Idempotent.**
  Every step checks its state first; rerun the installer at any time.

## Related

- [Install on a new machine](@/docs/start/install.md)
- [Review the installer and pin a commit](@/docs/how-to/pin-a-commit.md)
- [Environment variables](@/docs/reference/environment.md)
- [Security model](@/docs/concepts/security.md)
