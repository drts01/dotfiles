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

| Message                                          | Fix                                                                                                 |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| `ERROR: git is required.`                        | Install Git.                                                                                        |
| `ERROR: REPO_URL ... unauthenticated transport;` | Use an `https://` or `ssh://` URL, or a local path.                                                 |
| `fatal: unable to access ...`                    | Check network access to `github.com`; behind a proxy, set `https_proxy`.                            |
| `curl: (6) Could not resolve`                    | Check DNS, or [install with Git only](@/docs/how-to/install-without-mise.md#install-with-git-only). |

To install from a mirror, set `REPO_URL` on the `sh` that reads the pipe,
for example `| REPO_URL=https://git.example.com/dotfiles sh`.

## Pin errors

| Message                                                    | Cause                                          | Fix                                         |
| ---------------------------------------------------------- | ---------------------------------------------- | ------------------------------------------- |
| `fatal: remote error: upload-pack: not our ref`            | The commit does not exist on the remote        | Copy the full ID again from `git ls-remote` |
| `ERROR: fetched commit ... does not match DOTFILES_REF`    | The ID names a tag object, not a commit        | Pin the commit the tag points to            |
| `ERROR: ... is at ..., not DOTFILES_COMMIT ...`            | The pin is older than the installed commit     | Pin the installed commit or a later one     |
| `ERROR: ... is at ..., expected ...`                       | The pinned commit predates pinning support     | Pin a later commit                          |
| `ERROR: DOTFILES_COMMIT must be a full ... commit ID.`     | The deploy script received a short or bad ID   | Pass the full 40- or 64-character ID        |
| `ERROR: cannot determine the default branch ...`           | The remote did not report its default branch   | Set `DOTFILES_BRANCH=trunk`                 |

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
| `Warning: HEAD is detached; skipping pull.`                | Run `cd ~ && dotfiles switch trunk`, then update                        |

## Plugins are missing

The installer prints `Skipping <group> submodules (<tool> not found).` or `(excluded).` for each skipped group.
Install the tool, then [add the group](@/docs/how-to/choose-plugin-groups.md#add-a-group-later).

## Optional components are missing

| Message                                                   | Effect                     | Fix                                                                   |
| --------------------------------------------------------- | -------------------------- | --------------------------------------------------------------------- |
| `Warning: neither curl nor wget found; continuing ...`    | No mise                    | Install curl or wget, then rerun the installer                        |
| `Warning: mise installation failed; continuing ...`       | No mise                    | Rerun the installer, or install mise from <https://mise.jdx.dev>      |
| `Warning: 'prek' not found. Skipping git hooks ...`       | No pre-commit hook         | [Install the hook](@/docs/how-to/git-hooks.md)                        |
| `Warning: .../info/exclude contains local rules; ...`     | Shared ignore list unused  | Move the rules to `~/.config/git/ignore`, delete the file, then rerun |
| `Warning: .../info/exclude is already a symlink; ...`     | Shared ignore list unused  | Delete the symlink, then rerun                                        |

The dotfiles work without every component in this table.

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
