# SCaLE talk notes: dotfiles — the missing manual

## Working title

**dotfiles: The Missing Manual — `$HOME` the DevOps Way**

Alternatives: **dotfiles: the missing manual**, **`$HOME` the DevOps Way**

Use `$HOME`, not `HOME_DIR`; `$HOME` is the standard variable the audience recognizes.

## SCaLE 24x CFP facts

Source: <https://www.socallinuxexpo.org/scale/24x/cfp> (retrieved 2026-10-26).

- Conference: April 1–4, 2027, Pasadena Convention Center.
- **Submission deadline: November 1, 2026.**
  Notifications begin December 1, 2026.
- Session slot: about **45 minutes**.
- Speakers must present in person; travel is not funded; speakers receive a full conference pass.
- Required fields: title, **short abstract** (print), **long abstract** (online), speaker profile with photo,
  bio (**≤ 1000 characters, third person**), track, level, optional message to reviewers.
- Provided setup: hands-free microphone, handheld microphone, projector with HDMI.
- Slides must be in an open, non-proprietary format.
- No sales pitches.
- Multiple proposals are allowed.
- Notices come from `cfp@socallinuxexpo.org`; add it to contacts to avoid corporate spam filtering.

**Recommended track:** Developers, Platform Engineering & DevEx
(the topic explicitly lists local development environments and CLIs).
Alternatives: Systems & Infrastructure (configuration management) or the co-located DevOpsDayLA.

## TODO (ordered by priority)

### P0 — required before submitting (deadline 2026-11-01; target 2026-10-30)

- [ ] Confirm in-person availability for April 1–4, 2027, and self-funded travel.
- [x] Confirm the employer's policy on public speaking and on the public dotfiles content.
- [ ] Create or log in to the SCaLE CFP account; add `cfp@socallinuxexpo.org` to contacts.
- [ ] Select the final title.
- [ ] Finalize the short abstract and long abstract (drafts below).
- [x] Write the speaker bio (≤ 1000 characters, third person); see [Speaker bio](#speaker-bio).
- [ ] Select a photo.
- [ ] Select track and level.
- [ ] Finalize the message to reviewers (draft below).
- [ ] Push the bootstrap fixes and confirm a green `Bootstrap` CI run for every matrix job;
      the reviewer message claims the workflow exists.
- [ ] Submit.

### P1 — before submitting if the repository is linked in the proposal; otherwise before acceptance

- [x] Fix `.config/dotfiles/bootstrap.sh`: it downloaded and executed itself
      (infinite recursion), and the `SKIP_MISE_INSTALL` condition was inverted.
      The README install command uses this script.
      The entrypoint now fetches `mise-tasks/bootstrap.sh`, and mise is optional.
- [ ] Remove employer references from the public repository
      (`.ssh/config.d/everbridge##everbridge`, `git/UHG/.gitconfig`).
      Employer clearance is done and the employers are already public, so history does not need rewriting.
- [ ] Resolve the `##Darwin` / `##everbridge` yadm-style file names, which conflict with the "no templating" message.

### P2 — after submission, before notification (2026-12-01)

- [ ] Capture a reproducible shell-startup baseline from an old commit before further optimization.
- [x] Add a GitHub Actions workflow that bootstraps in a fresh non-root container
      and runs bootstrap twice (idempotency).
      This workflow is also the demo fallback.
      Done: the `bootstrap` job in `.github/workflows/ci.yaml` runs one parallel job per image plus a macOS host job;
      `mise run bootstrap:test:container` runs the same script locally.
- [ ] Inventory the checks actually enforced by hooks and CI.

### P3 — after acceptance (December–March)

- [ ] Decide the secrets workflow: Bitwarden Rust client (`rbw` or `bws`), age, fnox.
- [ ] Document the work-overlay mechanics without employer-sensitive details.
- [ ] Build and test the `dotfiles-starter` Copier template.
- [ ] Script the fresh-container demo from the same steps as the GitHub Actions workflow.
      `tests/bootstrap-container.sh` already runs locally and in CI;
      the stage demo still needs a visible user-facing install, not only the test output.
- [ ] Save the latest passing workflow run offline (screenshots or downloaded logs);
      the fallback must work without conference Wi-Fi.
- [ ] Decide whether the Zed limitation stays unresolved or receives a tested mitigation.
- [ ] Write slides in an open format; fit them to 45 minutes.
- [ ] Rehearse with a timer; dry run at a local meetup or user group if possible.
- [ ] Re-verify all repository statistics shortly before the talk.

## Submission drafts

### Short abstract (print)

> Most dotfiles guides stop at "put them in Git." This talk treats `$HOME` like a small production system: bootstrap
> it with only Git and a shell—no sudo, symlinks, or templates—then test and secure it. Includes a live demo from a
> fresh container to a working shell.

### Long abstract (online)

> AI made configuration cheap to write. It did not make it trustworthy. Most dotfiles guides end at "put them in
> Git"; this talk starts there and treats the home directory like a small production system.
>
> Attendees will learn how to:
>
> - Bootstrap a portable environment with only Git and a shell, without superuser access, symlink farms, or runtime
>   templates.
> - Manage dependencies through Git wherever possible.
> - Handle host and work differences with the include and override mechanisms formats already support.
> - Test deployment, not just syntax: clean containers, repeated runs, and CI.
> - Keep secrets out of a public repository, including the "secret zero" problem on a new machine.
> - Recognize when a bare-repository approach is the wrong fit.
>
> The session includes a live bootstrap from a fresh container, an honest list of unsolved problems, and a starter
> template attendees can use the same day. Assumes comfort with Git and a Unix shell.

**Abstract policy:** Git is the only named tool.
Name mise, submodules, hooks, CI tools, Bitwarden, age, fnox, and Copier in the detailed session description, slides,
or talk—not in the abstract.
"No third-party requirement" describes the *minimum bootstrap path*, not the fully provisioned environment.
AI is the motivation, not the subject; keep it to one sentence.

### Message to reviewers (draft)

> The talk is based on a public dotfiles repository maintained since 2019. CI runs linting, shell-startup tests, and a
> bootstrap test that deploys the dotfiles as a non-root user in fresh Debian, Alpine, Fedora, and Chainguard
> containers and on macOS, then repeats the bootstrap to check idempotency. The live demo runs the same steps, and a
> saved run of that workflow is the fallback if the network fails. Standard HDMI projection is sufficient. Tools
> covered in the talk body include Git submodules, mise (packages without sudo), pre-commit hooks, CI linting, a
> password-manager-based secrets workflow, and a Copier template (`dotfiles-starter`) released with the talk.
> No product pitch.

Present tense is valid only after the P0 green-CI item is checked; otherwise revert to the future-tense draft.

### Speaker bio

Source: `~/git/tmp/CFP-pinned-but-mutable/presentation/scale-24x-speaker-bios.md`
(Variant 1 + formal dotfiles hook, with "profiled" replaced by "reproducible").
Plain text for the CFP form; 760 characters.

> Carlos Meza is a Senior Software Engineer at UnitedHealthcare, where he works on CI/CD, platform automation, and
> developer experience on AWS. He found his way into tech through Linux user groups, local meetups, and SCaLE. His
> ten-plus years include engineering roles at Verizon, Everbridge, and The Walt Disney Studios. At Disney, he designed
> and built a Policy-as-Code service that enforced cloud compliance automatically. He chaired DevOpsDays LA, served on
> the Interop NOC team, and now leads a team on the SCaLE A/V crew. He has spoken at SCaLE five times since SCaLE 14x.
> He has kept his dotfiles in a public Git repository since 2019 and treats $HOME like a small production system:
> versioned, tested, and reproducible. GitHub: drts01 · LinkedIn: cmeza99

## Premise

I want the same environment wherever I work: at home, at work, or on a temporary machine.
Most dotfiles guides stop at "check them into Git."
This talk starts there and asks what it takes to make that environment portable, reproducible, maintainable, and safe.

The talk should be light-hearted, practical, and honest about what remains unsolved.

## Audience takeaway

A decision framework and a working starting point for managing `$HOME`:

1. Start with Git and a shell, without sudo.
2. Make optional tooling additive rather than a prerequisite for using the dotfiles.
3. Test deployment, not just configuration syntax.
4. Keep secrets out of the public repository.
5. Know when a bare-repo approach is the wrong fit.

Publish a **`dotfiles-starter` Copier template**.
Copier generates a starter repository once;
the resulting dotfiles do not require runtime templating or Copier to deploy.

## Narrative

**Opening problem:** "I want to sit down anywhere and feel at home."

**Then:** I could spend months tuning a `vimrc`.

**Now:** AI makes discovering, exploring, and iterating on tools much faster.
AI is the motivation for the talk, not its subject; do not spend more than the opening on it.
I can produce a useful Helix configuration in minutes—and still need to verify the keybindings.
The repository had 5 commits in 2025 and 223 in 2026 at the time these notes were drafted.
Do not equate commit count with quality; use it to illustrate a changed iteration speed.

**Central tension:** When configuration becomes cheap to produce, how do I trust it on every machine?

**Answer:** Treat `$HOME` like a small production system: provision it, pin dependencies, test it, profile it,
document it, and protect its secrets.

**Closing callback:** The bootstrap process should be demonstrably repeatable, not merely a command in a README.
Resolve the bootstrap bug introduced in the opening before the live demonstration.

**Closing line candidate:** "AI made configuration cheap.
The guardrails are what make it portable."

### Repository evidence for gags

Re-verify before the talk; numbers were taken on 2026-10-26.

- Commits per year: 2019: 4, 2021: 10, 2022: 33, 2023: 23, 2024: 18, 2025: 5, 2026: 223 (316 total).
- `fix(zsh)` 39 commits versus `feat(zsh)` 26.
- Helix, 2026-09-29/30: `add config` → `correct key bindings` → `correct status line` → `update configuration`
  → `remove keybindings`; Zed configuration was added the next day.
- Zed, 2026-10-23: "add and harden terminal allow list", followed by three "more permissive" commits.
- `.config/zed/AGENTS.md` and Cline rules: instructions for AI agents are version-controlled dotfiles.
- `.typos.toml` exists, yet the README says "Borne Shell" and commit messages contain "grammer" and "managment". <!-- # typos: ignore -->
- Submodule commits: 15 across `fix(submodules)`, `fix(submodule)`, and `feat(submodules)`.
- Cold open: the bootstrap script downloads and executes itself (`curl | sh | curl | sh …`).
- Writing the bootstrap test exposed more bugs than the recursion: an inverted `SKIP_MISE_INSTALL`,
  a conflict-backup parser that never matched
  (`read` strips the leading tab git uses to mark paths),
  a missing fetch refspec, a detached HEAD aborting under `set -e`, and `git submodule` run outside the work tree.
  Use as evidence for "test deployment, not syntax."
- A corporate network blocked or intercepted three of four test images' sources
  (Alpine CDN, `deb.debian.org`, `cgr.dev` blob storage); the test runner gained mirror overrides.
- Audience participation: "Raise your hand if your dotfiles have a commit message that just says 'update'."
  (This repository has `Update config` twice on 2021-10-01.)

## Constraints and architecture

- No sudo for the portable path.
- Only Git and a shell required to get started.
- No runtime templating.
- Prefer real files in `$HOME` over symlink deployment.
- Personal dotfiles are the portable base.
- Work-specific files live in a separate, private repository.
- mise manages packages and optional tools after the minimal setup is usable.
- Submodules pin third-party source such as plugins and themes; they are not a general binary package manager.

### Why a bare repository?

The home directory is the working tree: edit files where applications use them,
then use Git to review and commit changes.
There is no separate deploy or relink step.

Compare this honestly with symlink managers and templating systems.
The advantage is a small bootstrap surface; the cost is weaker support for host-specific configuration,
especially formats without includes or overrides.
Do not claim a bare repository is universally best.

| Approach        | Strength                                                | Cost                                                         |
| --------------- | ------------------------------------------------------- | ------------------------------------------------------------ |
| Bare repository | Git and shell are enough; no relink or render step      | `$HOME` is a hazardous working tree; host differences harder |
| Symlink manager | Repository and home directory are clearly separated     | Link creation and maintenance become deployment steps        |
| Templating tool | Strong host-specific configuration                      | Another dependency; source and target can drift              |

Without templating, put host differences where formats already support them: git `includeIf`, ssh `Include` and `Match`,
shell `.d/` directories and `uname` conditionals, Alacritty `import`, and untracked local override files.

Bare-repository gotchas worth a slide:

- Set `status.showUntrackedFiles no`.
- A bare clone has no `remote.origin.fetch` refspec; set it or tracking branches behave unexpectedly.
- A bare repository has no index until the first checkout; key "already installed" on the index, not the directory.
- `git submodule` requires the current directory to be inside the work tree, even with `--work-tree`.
- Never export `GIT_DIR` globally.

**Bootstrap idea:** Git can be the installer, with no curl or wget required
(documented in the README):
`git clone --bare --single-branch --depth=1 <url> ~/.local/share/dotfiles`,
then `sh -c "$(git --git-dir="$HOME/.local/share/dotfiles" show HEAD:.config/dotfiles/mise-tasks/bootstrap.sh)"`.
The bootstrap test covers this path.

### Work overlay

The work repository contains work-specific configuration,
including `mise.local.toml` and additional shell startup files.
Explain how the repositories avoid tracking the same path.
Treat the second repository as both a useful boundary and a real operational cost.

Model: the personal base defines extension points; the private work repository fills them
(like a base image plus layers).
Both share `$HOME` as the working tree with separate Git directories.
No file may be tracked by both repositories.

### Dependencies

- Submodules keep as much as possible managed through Git alone: one tool to clone, pin, review, and update.
  Pinning to a commit is a side benefit; do not claim it beats plugin managers, several of which support lockfiles.
  Explain initialization, detached HEADs, and updates.
- mise installs packages into the user's home without sudo; discuss lockfiles where they apply.
- Verify which dependency types Renovate actually updates before claiming it on a slide.
- Modern tools (`bat`, `eza`, `atuin`) are examples, not the subject.
  Show graceful fallback on a minimal machine.

## Proposed full-session flow

Fit to a 45-minute slot; times are targets.

1. **The problem and the vimrc gag (0–4):** Same environment everywhere; AI changed how quickly I can experiment.
2. **Git is the beginning, not the end (4–9):** Bare repository, checkout, portability,
   and the symlink/template tradeoff.
3. **Dependencies (9–13):** Submodules keep third-party source in Git; mise for packages without sudo.
4. **Guardrails (13–21):** Pre-commit checks, CI linting, shell tests, bootstrap tests, and documentation.
   One slide on startup time: a single measured before/after and the tool used—no profiling deep dive.
5. **Secrets (21–27):** Bitwarden as the source of truth; evaluate the Rust CLI client, age,
   and fnox for retrieval or injection.
   Explain what remains on disk and in the process environment.
6. **Work and home (27–30):** Portable base plus private work overlay.
7. **Fresh-container demo (30–37):** Minimal machine to configured environment;
   the GitHub Actions workflow runs the same steps, and a saved run is the offline fallback.
8. **Limitations (37–40):** What the approach cannot cleanly solve.
9. **Takeaway (40–45):** `dotfiles-starter`, a checklist, a link the audience can use, and questions.

Cut candidates if over time: merge the work overlay into limitations; shorten documentation to one slide.

## Testing and profiling

Testing layers:

1. Pre-commit checks catch problems before a commit.
2. CI repeats checks without relying on local hooks.
3. Shell tests (`tests/shell.sh`, `tests/source-cache.sh`) cover startup under supported shells.
4. Integration tests (`tests/bootstrap.sh`) bootstrap without mise in clean, non-root containers: Debian (dash), Alpine
   (BusyBox `sh`), Fedora (bash), Chainguard/Wolfi (dash, wget-only), plus a macOS runner.
   Each image is a parallel CI job; `tests/bootstrap-container.sh` runs the same matrix locally with podman or docker.
5. Idempotency: run bootstrap twice; the `$HOME` file list and `HEAD` are unchanged
   and `dotfiles status --porcelain` stays empty.
   Upstream commits fast-forward.
6. The doctor task reports missing or inconsistent setup.
7. Profiling checks whether a correct setup is also pleasant to use (supporting point; one slide).

**Slide idea:** "The demo is a CI job."

Profiling tools:

- `bench/shell-startup.sh` (`hyperfine`, isolated home): startup-to-exit wall time.
- `zsh-bench`: perceived first-prompt and input lag.
- `zmodload zsh/zprof`: per-function time.
- `zsh -x` with a timestamped `PS4`; `bash -x` with `EPOCHREALTIME` (bash 5+; macOS ships bash 3.2).
- `git bisect run` with a time threshold to find regressions.

Baseline capture: create a worktree at an old commit, copy the current bench script into it, and run it there;
the script derives its root from its own location.

## Demo and verification plan

- Use a non-root account in a fresh container.
- Separate **minimal bootstrap** (Git and shell) from **optional provisioning** (mise and managed tools).
  Show the elapsed time for each separately.
- Run the bootstrap twice and check that the second run is safe.
- Run shell tests and the repository's doctor task.
- Profile shell startup with the existing `bench/shell-startup.sh`.
- Run the demo procedure in the GitHub Actions container workflow; save a passing run offline
  (screenshots or downloaded logs) as the fallback for unreliable conference networking.
- Never demonstrate with real secrets or work-specific configuration.
- Rehearse the demo against the pushed `trunk` entrypoint, not a working-tree copy;
  the test uses `RAW_URL=file://…`, the audience uses `raw.githubusercontent.com`.

## Secrets questions to resolve

- Confirm which Bitwarden Rust CLI client to use and how it handles local vault data.
- Decide whether age and/or fnox solve a concrete problem here; avoid adding them solely to fill a slide.
- Decide what is permitted in a temporary machine's environment, files, and shell history.
- Keep private keys and plaintext secrets out of the public dotfiles repository.
- Explain "secret zero": a fresh machine still needs a trusted way to authenticate.
- A committed secret must be rotated; deleting it in a later commit is insufficient.
- AI agents running in a terminal inherit its environment; prefer project-scoped secrets over global exports.
- Prefer per-machine or hardware-backed SSH keys over syncing private keys.
- Demo with fake credentials only, e.g., a pre-commit hook blocking a fake key.

## Limitations slide

- Zed rewrites its single `settings.json`,
  making Git diffs noisy and environment-specific settings difficult without templating
  or application-supported overrides.
- Work requires a second dotfiles repository and a separate provisioning step.
- A bare repository makes `$HOME` the working tree; broad `git clean`, `git add .`, or destructive resets are hazardous.
- Formats without includes or overrides do not layer neatly.
- Submodules and optional tools add update and network costs.
- Bootstrap cannot make credentials appear on an untrusted machine.
- Linux and macOS differ; portability must be tested rather than assumed.
- Restricted networks (TLS interception, blocked mirrors or registries) can break a bootstrap that passes in CI.
- No sudo has a boundary: system packages and `/etc` are out of scope, and `chsh` to a user-installed shell
  fails because it is not listed in `/etc/shells`.

Leave the Zed issue visibly unresolved if there is no reliable solution.
It is an honest example of where the chosen architecture strains.

## `dotfiles-starter` scope

Keep the first version small: bare-repo bootstrap, a minimal shell configuration, optional mise integration,
an extension point for private overrides, tests, CI, documentation, and a safe secrets policy.
Copier is a **creation-time convenience**, not a requirement for deploying the generated repository.

Notes:

- Store the answers file under `.config/dotfiles/` rather than at the `$HOME` root.
- `copier update` expects a regular working copy; run updates in a normal clone, not the bare-repository `$HOME`.
- Expect the audience question "You said no templating"; answer: templates run once at creation, never at deploy.

## Evidence to collect before writing slides

- A reproducible old and current shell-startup measurement, including machine and measurement method.
- A passing `Bootstrap` CI run (all matrix jobs) saved offline; the procedure and idempotency test exist.
- The current CI checks and what they do *not* cover
  (e.g. the bootstrap test runs without mise, so `update` and `mise bootstrap` are untested in CI).
- A scrubbed history excerpt illustrating the vim → Helix iteration.
- Confirmation of the Bitwarden client and work-overlay mechanics.
