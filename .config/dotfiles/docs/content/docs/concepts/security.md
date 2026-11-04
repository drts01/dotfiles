+++
title = "Security model"
description = "What the installer authenticates, what a commit pin covers, and where credentials belong."
weight = 40

[extra]
type = "explanation"
+++

The installer changes files in `$HOME` that hold shell, SSH, and Git settings, so this page states what it verifies,
what it trusts, and where credentials belong.

## Trust boundaries

A full commit ID in `DOTFILES_REF` pins the repository content.
Everything the installer fetches from that commit is verified by Git object IDs.
Downloads from outside the commit rely on TLS alone.

| Component                        | Fetched from                    | Authenticated by           | Covered by a commit pin   |
| -------------------------------- | ------------------------------- | -------------------------- | ------------------------- |
| Entrypoint, `bootstrap.sh`       | `raw.githubusercontent.com`     | TLS                        | Only if you review it     |
| Dotfiles and deploy script       | `REPO_URL`                      | TLS or SSH, Git object IDs | Yes                       |
| Plugin submodules                | GitHub and Codeberg over HTTPS  | TLS, Git object IDs        | Yes, by gitlink           |
| mise installer                   | `https://mise.run`              | TLS                        | No                        |
| `prek`, run by the Git hooks     | Release assets, through mise    | Checksums in `mise.lock`   | Yes, the lock is tracked  |
| Remote hook repositories         | GitHub, through `prek`          | TLS, Git object IDs        | Yes, by `rev` commit hash |

- A gitlink records the exact commit of each submodule, so a pinned commit fixes every plugin version.
  The hosts must still serve those commits; a deleted repository breaks the install, not its integrity.
- The entrypoint runs before any pin applies.
  [Review the installer and pin a commit](@/docs/how-to/pin-a-commit.md) downloads it at the pinned commit
  so you read the same script that runs.
- `REPO_URL` must use `https://`, `ssh://`, or a local path.
  The installer rejects `http://`, `git://`, and `ftp://`, which do not authenticate the server.

## What a pin does not cover

- **The mise installer.**
  `https://mise.run` is a trust-on-first-use download, outside commit verification.
  `mise.lock` records tool versions and checksums, not the version of mise itself,
  so the installer cannot pin mise from the lock.
  `DOTFILES_SKIP_MISE_INSTALL=1` removes the download;
  [install without mise](@/docs/how-to/install-without-mise.md) for a Git-only install.
- **The machine toolchain.**
  `~/.config/mise/mise.lock` is ignored by the repository, so tools installed by `mise bootstrap` resolve per machine.
- **Who wrote a commit.**
  A commit ID proves that content did not change after you reviewed it; it does not prove authorship.
  The repository does not sign its commits yet.

## Secrets

The repository tracks configuration, never credentials.

| Kind                                  | Where it lives                                                            |
| ------------------------------------- | ------------------------------------------------------------------------- |
| SSH private keys                      | `~/.ssh/`, untracked; the repository tracks only SSH client configuration |
| Tokens and machine-specific variables | An untracked module such as `~/.config/sh/sh.d/95_local.sh`               |
| Files the installer replaced          | `~/.df-bak`, mode `700`, ignored by the repository                        |
| Tool state, caches, and shell history | Under `~/.local/share` and `~/.cache`, untracked                          |

Three controls keep credentials out of commits:

- `status.showUntrackedFiles=no` hides untracked files, so you add files by name.
  `dotfiles add -A` defeats this control; see [The bare repository](@/docs/concepts/bare-repo.md#untracked-files).
- The tracked ignore list, linked as `info/exclude`, excludes `~/.df-bak` and the bare repository.
- The `detect-private-key` hook blocks a commit that contains a private key header;
  see [Hooks](@/docs/reference/hooks.md).
  It does not detect API tokens or passwords.

## Related

- [How the installer works](@/docs/concepts/bootstrap-flow.md)
- [Review the installer and pin a commit](@/docs/how-to/pin-a-commit.md)
- [Customize the shell](@/docs/how-to/customize-shell.md)
