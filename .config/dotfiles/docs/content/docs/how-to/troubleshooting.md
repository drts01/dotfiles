+++
title = "Troubleshoot an install"
description = "Match an installer, update, or doctor message to its cause and fix."
weight = 90

[extra]
type = "how-to"
+++

Find the message you see, then apply its fix.
Rerun the installer after every fix; each step is idempotent and resumes an interrupted install.

## The installer cannot fetch the repository

The installer resolves the commit before it changes `$HOME`, so a failed fetch leaves your files unchanged.

For `ERROR: git is required.`, [install Git](#doctor-git-missing).
For `fatal: unable to access ...`, check network access to `github.com`; behind a proxy, set `https_proxy`.
For `curl: (6) Could not resolve`, check DNS,
or [install with Git only](@/docs/how-to/install-without-mise.md#install-with-git-only).

### Repository transport is unauthenticated {#installer-transport}

For `ERROR: REPO_URL ... uses an unauthenticated transport`, use an `https://` or `ssh://` URL, or a local path.

To install from a mirror, set `REPO_URL` on the `sh` that reads the pipe,
for example `| REPO_URL=https://git.example.com/dotfiles sh`.

## Pin errors

For `fatal: remote error: upload-pack: not our ref`, the commit does not exist on the remote.
Copy the full ID again from `git ls-remote`.

### Fetched commit differs from the requested pin {#installer-pin-mismatch}

For `ERROR: fetched commit ... does not match DOTFILES_REF`, the ID may name a tag object rather than a commit.
Pin the commit the tag points to.

### Installed commit differs from DOTFILES_COMMIT {#installer-pin-behind}

For `ERROR: ... is at ..., not DOTFILES_COMMIT ...`, the installed commit is newer, diverged, or detached.
Pin the installed commit or a later commit on its branch.

### Pinned commit predates pinning support {#installer-pin-unsupported}

For `ERROR: ... is at ..., expected ...`, the pinned commit may predate pinning support.
Pin a later commit with `DOTFILES_COMMIT` support in `mise-tasks/bootstrap.sh`.

### Invalid commit ID {#installer-invalid-commit}

For `ERROR: DOTFILES_COMMIT must be a full ... commit ID`, pass the full 40- or 64-character lowercase commit ID.

### Default branch is unknown {#installer-default-branch}

For `ERROR: cannot determine the default branch ...`, set `DOTFILES_BRANCH` to the name of the branch you want to track.

A failed pin leaves the installed checkout unchanged.
Print the installed commit with `git --git-dir="$HOME/.local/share/dotfiles" rev-parse HEAD`.

## Checkout conflicts

`Backing up pre-existing dotfiles to ~/.df-bak...` is expected on a machine with existing dotfiles.
The installer moves each conflicting file, then retries the checkout.

If the retry fails, Git names the blocking path, for example a directory where the repository tracks a file.
Move that path out of `$HOME`, then rerun the installer.

## Update does not fast-forward

| Message                                                    | Fix                                                                     |
| ---------------------------------------------------------- | ----------------------------------------------------------------------- |
| `fatal: Not possible to fast-forward, aborting.`           | Rebase local commits: `cd ~ && dotfiles pull --rebase origin trunk`     |
| `Your local changes ... would be overwritten`              | Run `cd ~ && dotfiles stash`, update, then `dotfiles stash pop`         |

### Detached HEAD skips updates {#installer-detached-head}

For `Warning: HEAD is detached; skipping pull.`, run `cd ~ && dotfiles switch trunk`, then update.

## Plugin group selection is invalid {#installer-invalid-groups}

For `ERROR: DOTFILES_SUBMODULES must be a comma-separated list`
or `ERROR: DOTFILES_SKIP_SUBMODULES must be a comma-separated list`, supply one or more of `zsh,nvim,lua,docs`,
or use a supported special value.
See [Choose plugin groups](@/docs/how-to/choose-plugin-groups.md) for the supported values.

## Plugins are missing

The installer prints `Skipping <group> submodules (<tool> not found).` or `(excluded).` for each skipped group.
Install the tool, then [add the group](@/docs/how-to/choose-plugin-groups.md#add-a-group-later).

## Optional components are missing

The dotfiles work without mise, prek, or the shared ignore list.

### No downloader for mise {#installer-no-downloader}

For `Warning: neither curl nor wget found; continuing without mise.`, install curl or wget, then rerun the installer.

### mise installation failed {#installer-mise-failed}

For `Warning: mise installation failed; continuing without mise.`, rerun the installer,
or install mise from <https://mise.jdx.dev>.

### prek is missing {#installer-prek-missing}

For `Warning: 'prek' not found. Skipping git hooks installation.`, [install the hook](@/docs/how-to/git-hooks.md).

### Hook file was not generated {#installer-hook-not-generated}

For `ERROR: Hook file was not generated`,
check that `prek install` can write to the bare repository's `hooks` directory,
then [reinstall the hook](@/docs/how-to/git-hooks.md#install-the-hook).

### Ignore list is missing {#installer-ignore-missing}

For `ERROR: Missing tracked ignore list`, restore `.config/dotfiles/gitignore` from the repository,
then rerun the installer.

### Git exclude contains local rules {#installer-exclude-local-rules}

For `Warning: .../info/exclude contains local rules`, move the rules to `~/.config/git/ignore`,
then move the exclude file aside and rerun the installer.

### Git exclude is another symlink {#installer-exclude-symlink}

For `Warning: .../info/exclude is already a symlink`, inspect the symlink target.
Move it aside only if you want the shared ignore list, then rerun the installer.

### Git exclude backup already exists {#installer-exclude-backup-exists}

For `Warning: .../info/exclude.before-dotfiles already exists`,
inspect the existing backup and `info/exclude` before moving either file; rerun the installer to link the shared list.

## Doctor output

`sh ~/.config/dotfiles/mise-tasks/doctor.sh` prints one line per check.

### Git is missing {#doctor-git-missing}

`Binary: git ... FAIL` means Git is required.
Install Git, then rerun the installer.

### Bare repository path is missing {#doctor-repo-missing}

`Bare repository path ... FAIL` means the repository has not been created at the configured path.
[Install the dotfiles](@/docs/start/install.md).

### Repository is not bare {#doctor-repo-not-bare}

`Bare repository integrity ... FAIL` means the directory is not a usable bare Git repository.
Move it aside for inspection, then [reinstall](@/docs/start/install.md).
Do not delete it until you have checked it for local commits or other data.

### Untracked-file setting is missing {#doctor-untracked-setting}

`Git untracked optimization ... FAIL` means `status.showUntrackedFiles` is not `no`.
Run `git --git-dir="$HOME/.local/share/dotfiles" config --local status.showUntrackedFiles no`.
If you set a custom `DEST_DIR`, use that path instead.

### Git status failed {#doctor-status-failed}

`Tracked files ... FAIL` means Git could not read the working-tree status.
Run `cd ~ && dotfiles status` to see Git's error.

### Pre-commit hook is not executable {#doctor-hook-not-executable}

`Pre-commit hook ... FAIL` means the installed hook cannot run.
Run `chmod +x ~/.local/share/dotfiles/hooks/pre-commit`.
If you set a custom `DEST_DIR`, use that path instead.

### Hook lacks bare-repository overrides {#doctor-hook-missing-override}

`Bare-repo hook configuration ... FAIL` means the installed hook does not set `GIT_DIR` and `GIT_WORK_TREE`.
[Reinstall the hook](@/docs/how-to/git-hooks.md#install-the-hook).

Warnings do not fail the installation checks:

| Check              | Warning           | Fix                                                        |
| ------------------ | ----------------- | ---------------------------------------------------------- |
| `Tracked files`    | changes present   | Review `dotfiles status`; commit or restore                |
| `Binary: mise`     | not installed     | Optional; the dotfiles work without mise                   |
| `Binary: prek`     | not installed     | Optional; required only for Git hooks                      |
| `Pre-commit hook`  | not installed     | Optional; [install the hook](@/docs/how-to/git-hooks.md)   |

## Related

- [How the installer works](@/docs/concepts/bootstrap-flow.md)
- [Environment variables](@/docs/reference/environment.md)
