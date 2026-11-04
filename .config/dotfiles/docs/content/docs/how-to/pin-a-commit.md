+++
title = "Review the installer and pin a commit"
description = "Read the installer before it runs and deploy exactly the commit you reviewed."
weight = 10

[extra]
type = "how-to"
+++

Deploy exactly the commit you reviewed, so a later push cannot change what runs on your machine.

## Prerequisites

- Git, a POSIX `sh`, and curl.

## Steps

1. Find the commit to install; copy the full 40-character ID from the first column:

   ```bash
   git ls-remote https://github.com/drts01/dotfiles trunk
   ```

2. Download the entrypoint at that commit, replacing `<commit>`:

   ```bash
   curl -fsSLo dotfiles-bootstrap.sh https://raw.githubusercontent.com/drts01/dotfiles/<commit>/.config/dotfiles/bootstrap.sh
   ```

3. Read the script:

   ```bash
   less dotfiles-bootstrap.sh
   ```

4. Run it pinned to the same commit:

   ```bash
   DOTFILES_REF=<commit> sh dotfiles-bootstrap.sh
   ```

Git verifies a full commit ID while it fetches.
Every deployed file, including the deploy script, comes from that commit.
`DOTFILES_REF` also accepts a branch or a tag; Git installs whatever commit it names at fetch time.

The pin does not cover the mise installer from `https://mise.run`.
To skip it, add `DOTFILES_SKIP_MISE_INSTALL=1` to the command in step 4.
[Security model](@/docs/concepts/security.md) lists what a pin covers.

## Verify

This command prints the pinned commit ID:

```bash
git --git-dir="$HOME/.local/share/dotfiles" rev-parse HEAD
```

## Undo

A pin applies to one run.
[Update](@/docs/how-to/update.md) without `DOTFILES_REF` to follow the default branch again.

## Troubleshoot

- A pin older than the installed commit fails and leaves the checkout unchanged.
- A commit that predates pinning support deploys the default branch, then fails.

See [Pin errors](@/docs/how-to/troubleshooting.md#pin-errors).

## Related

- [How the installer works](@/docs/concepts/bootstrap-flow.md)
- [Environment variables](@/docs/reference/environment.md)
