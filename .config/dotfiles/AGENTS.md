# Dotfiles agent instructions

Apply these instructions to repository-wide work when explicitly loaded.
Resolve command and code paths below from the repository root; resolve Markdown links from this file.

## Protect the deployment boundary

Develop in a regular clone. The installed bare repository uses `$HOME` as its work tree
and deploys every tracked file there.
Keep repository-only additions under `.config/dotfiles/` or `.github/`.
Keep this file here: a tracked root `AGENTS.md` would become `~/AGENTS.md` and could affect unrelated projects.

Use `sh .config/dotfiles/dev-setup.sh` to prepare a new clone.
It installs tools and hooks and links ignored root development configs; reconcile conflicts manually.
Reserve both bootstrap scripts and the `install:gitignore` / `install:git-hooks` tasks for deployed installations,
not development clones.

## Preserve shell behavior

Keep bootstrap dependent only on Git and POSIX `sh`; treat mise and downloaders as optional enhancements.
Keep shared modules in `.config/sh/` portable across `sh`, Bash, and Zsh.
Preserve quiet non-interactive startup, numbered module order, and operation without optional tools.
Keep shell-specific behavior in its native startup files or established guarded branches.
Before changing startup order, completion, history, or initialization caches,
read [Shell startup](docs/content/docs/concepts/shell-startup.md).
Follow the scoped `.editorconfig`; anchor new section globs with `/` to avoid affecting other projects under `$HOME`.
Add plugins and themes as shallow submodules through `.gitmodules`.

## Validate the changed behavior

Run applicable checks from the configured clone root:

- Shared shell behavior: `mise run shell:test`.
- Shell-specific startup: `mise run shell:test:posix`, `mise run shell:test:bash`, or `mise run shell:test:zsh`.
- Installer behavior: `mise run bootstrap:test`; use `mise run bootstrap:test:container` for Linux container coverage.
- Documentation pages: `mise run docs:check -- --skip-external-links` and `mise run docs:build`.

Use ShellSpec `*_spec.sh` files under `.config/dotfiles/spec/` for unit and startup regressions.
Use the isolated harnesses under `.config/dotfiles/tests/` for deployment and tool integration tests.
Before selecting integration tests or initializing their submodules, read
[Test the dotfiles](docs/content/docs/contributing/testing.md).
Inspect `dev-tasks.toml` and `prek.toml` for current task and hook definitions.
Run targeted hooks where possible; `mise run lint` applies fixes across the repository.
Review the diff for unrelated rewrites.

## Reach the authoritative guidance

- Before changing clone setup, tool pins, locks, or hooks, read
  [Set up a development clone](docs/content/docs/contributing/development.md).
  Keep development and deployment lockfiles separate; keep `.config/mise/` excluded from clone configuration.
- Before adding documentation pages or ADRs, read
  [Write documentation](docs/content/docs/contributing/documentation.md) for page types, front matter, and links.
- Before changing deployment behavior, read
  [Bootstrap design](docs/content/docs/concepts/bootstrap-flow.md).
- Use small atomic scoped Conventional Commits, for example `fix(shell): preserve listing failure status`.
