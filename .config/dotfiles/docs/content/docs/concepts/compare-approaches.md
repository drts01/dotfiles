+++
title = "Is this approach right for you?"
description = "What a bare repository in $HOME optimizes for, what it costs, and when another dotfiles tool fits better."
weight = 5

[extra]
type = "explanation"
+++

This repository tracks dotfiles with a bare Git repository whose working tree is `$HOME`.
The approach suits some setups and not others; this page states both.

## What the design optimizes for

- **No root access.** Every step writes only to `$HOME`.
- **Git and a POSIX shell only.**
  No dotfiles manager, language runtime,
  or package manager is required. mise and plugins are optional and add features on top.
- **Real files in place.**
  Each tracked file is a regular file at its own path in `$HOME`, not a link or a render.
  Editors and tools see the real path.
- **No runtime templating.**
  A file's content in Git is its content on every machine; no apply step generates it.

## What it costs

- **`$HOME` is a working tree.**
  Broad commands such as `dotfiles add -A` stage every file below the current directory, including credentials;
  see [The bare repository](@/docs/concepts/bare-repo.md#untracked-files).
- **Host differences need native mechanisms.**
  Without templates, machine-specific settings go where each format already supports them: Git `includeIf`,
  SSH `Include`, shell `.d/` directories, `uname` conditionals,
  and untracked local files such as `~/.config/sh/sh.d/95_local.sh`.
  Formats without includes or conditionals are harder to vary per machine.
- **Rollback is Git.**
  Revert or check out an earlier commit; installed packages have no generation history.
- **No secret management.**
  The repository keeps credentials out of commits but does not store, encrypt, or fetch them;
  see [Security model](@/docs/concepts/security.md#secrets).

## Compare approaches

| Approach                    | Examples                       | New knowledge required    | Strength                                                                 | Cost                                                                     |
| --------------------------- | ------------------------------ | ------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| Bare repository             | This repository                | Git, POSIX shell          | Nothing to install; no link or apply step                                | `$HOME` is a working tree; host differences rely on each format          |
| Multiple bare repositories  | [vcsh][vcsh]                   | Git, vcsh                 | One repository per tool; pick and mix per machine                        | Another tool; several repositories to keep in sync                       |
| Symlink farm                | [GNU Stow][stow]               | Stow package layout       | Repository stays outside `$HOME`                                         | Creating links becomes a deploy step; requires Perl                      |
| Git wrapper with alternates | [yadm][yadm]                   | Git, yadm file suffixes   | Git commands plus per-host alternates, templates, and encryption         | Another dependency; alternates are symlinks that yadm manages            |
| Source-state manager        | [chezmoi][chezmoi]             | chezmoi CLI, Go templates | Per-machine templates and password-manager integration in one binary     | Files in `$HOME` are generated; edit the source, then apply              |
| Declarative                 | [Nix Home Manager][hm]         | Nix language and store    | Packages and configuration together; `home-manager switch --rollback`    | Steep learning curve; the Nix installer uses `sudo` to create `/nix`     |

## Choose something else when

- Many machines need different contents in files that support no includes or conditionals:
  use templates in chezmoi or alternates in yadm.
- The repository must hold secrets: use chezmoi's password-manager functions or yadm's encryption.
- You want packages and configuration versioned together with rollback, and can install Nix: use Home Manager.
- You want separate repositories per tool or per role: use vcsh.
- You want the repository outside `$HOME` and accept a link step: use GNU Stow.

## Prior art

The bare-repository technique comes from a Hacker News comment by `StreakyCobra`,
popularized by Atlassian's [Dotfiles: Best way to store in a bare Git repository][atlassian].
This repository adds a pinned, repeatable installer, conflict backups, health checks,
and installation tests on several platforms; see [How the installer works](@/docs/concepts/bootstrap-flow.md).

## Related

- [The bare repository](@/docs/concepts/bare-repo.md)
- [Security model](@/docs/concepts/security.md)
- [Platform support](@/docs/reference/support.md)

Decisions: [ADR-0001](@/docs/contributing/decisions/0001-bare-repository.md),
[ADR-0002](@/docs/contributing/decisions/0002-minimal-requirements.md).

[atlassian]: https://www.atlassian.com/git/tutorials/dotfiles
[chezmoi]: https://www.chezmoi.io/why-use-chezmoi/
[hm]: https://nix-community.github.io/home-manager/
[stow]: https://www.gnu.org/software/stow/
[vcsh]: https://github.com/RichiH/vcsh
[yadm]: https://yadm.io/docs/overview
