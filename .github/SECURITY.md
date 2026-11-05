# Security policy

## Supported versions

Only the latest commit on `trunk` receives fixes.
The repository has no releases; pin a commit with `DOTFILES_REF` and update to a fixed commit.

## Report a vulnerability

Report privately through GitHub:
[open a private vulnerability report](https://github.com/drts01/dotfiles/security/advisories/new).

Do not open a public issue, discussion, or pull request for a vulnerability.

Include:

- Affected file or task, for example `bootstrap.sh` or `mise-tasks/bootstrap.sh`
- Commit ID (`dotfiles rev-parse HEAD`, or the `DOTFILES_REF` you used)
- Steps to reproduce and the impact
- Operating system and shell

Remove tokens, hostnames, and usernames from logs before you send them.

This is a personal project maintained on a best-effort basis.
Expect an acknowledgement in the report thread;
fixes land on `trunk` and are noted in the [changelog](https://drts01.github.io/dotfiles/docs/reference/changelog/).

## Scope

In scope:

- The installer entrypoint (`.config/dotfiles/bootstrap.sh`) and deploy script (`mise-tasks/bootstrap.sh`)
- Tasks under `.config/dotfiles/mise-tasks/`, including Git hook installation
- Tracked configuration that weakens a tool's security, such as SSH or Git settings
- Credentials or private data committed to the repository
- GitHub Actions workflows in `.github/workflows/`

Out of scope; report these upstream:

- Plugin submodules and their hosts
- mise, prek, and tools installed through mise
- The `devlab-theme` documentation theme

## Security model

Read the [security model](https://drts01.github.io/dotfiles/docs/concepts/security/)
for what the installer authenticates, what a commit pin covers, and where credentials belong.
