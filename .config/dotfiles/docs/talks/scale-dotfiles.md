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
- [ ] Confirm the employer's policy on public speaking and on the public dotfiles content.
- [ ] Create or log in to the SCaLE CFP account; add `cfp@socallinuxexpo.org` to contacts.
- [ ] Select the final title.
- [ ] Finalize the short abstract and long abstract (drafts below).
- [ ] Write the speaker bio (≤ 1000 characters, third person) and select a photo.
- [ ] Select track and level.
- [ ] Finalize the message to reviewers (draft below).
- [ ] Submit.

### P1 — before submitting if the repository is linked in the proposal; otherwise before acceptance

- [ ] Fix `.config/dotfiles/bootstrap.sh`: it downloads and executes itself
      (infinite recursion), and the `SKIP_MISE_INSTALL` condition is inverted.
      The README install command uses this script.
- [ ] Remove or privatize employer-identifying files from the public repository
      (`.ssh/config.d/everbridge##everbridge`, `git/UHG/.gitconfig`); decide whether history must be rewritten.
- [ ] Resolve the `##Darwin` / `##everbridge` yadm-style file names, which conflict with the "no templating" message.

### P2 — after submission, before notification (2026-12-01)

- [ ] Capture a reproducible shell-startup baseline from an old commit before further optimization.
- [ ] Add a CI job that bootstraps in a fresh non-root container and runs bootstrap twice (idempotency).
- [ ] Inventory the checks actually enforced by hooks and CI.

### P3 — after acceptance (December–March)

- [ ] Decide the secrets workflow: Bitwarden Rust client (`rbw` or `bws`), age, fnox.
- [ ] Document the work-overlay mechanics without employer-sensitive details.
- [ ] Build and test the `dotfiles-starter` Copier template.
- [ ] Script the fresh-container demo; run it in CI; record a fallback.
- [ ] Decide whether the Zed limitation stays unresolved or receives a tested mitigation.
- [ ] Write slides in an open format; fit them to 45 minutes.
- [ ] Rehearse with a timer; dry run at a local meetup or user group if possible.
- [ ] Re-verify all repository statistics shortly before the talk.

## Submission drafts

### Short abstract (print)

> Most dotfiles guides stop at "put them in Git." This talk starts there: an opinionated way to carry the same
> environment to home, work, and temporary machines with only Git and a shell—no sudo, symlinks, or templates—then
> test, profile, and secure it. Includes a live fresh-container demo.

### Long abstract (online)

> I want the same environment wherever I sit: at home, at work, or on a machine I will use for one afternoon. Most dotfiles guides end at "put them in Git." This talk starts there. We will build a portable home-directory setup without superuser access, symlink farms, or runtime templates; then add dependency management, testing, profiling, documentation, and a plan for secrets. Along the way, I will show what a bare Git repository does well, where it gets awkward, and how AI changed the speed at which I discover and iterate on tools. We will go from a fresh container to a configured environment live—and examine the failures that made the process worth testing.
>
> Attendees will leave with a decision framework for managing their home directory, an honest list of limitations,
> and a starter template they can use the same day.

### Message to reviewers (draft)

> The talk is based on a public dotfiles repository maintained since 2019. The live demo bootstraps a fresh,
> non-root container to a configured environment; the same procedure runs in CI, and a recording is available as a
> fallback if the network fails. Standard HDMI projection is sufficient. Tools covered in the talk body include mise
> (packages without sudo), Git submodules, pre-commit hooks, CI linting, hyperfine for startup profiling, Bitwarden
> for secrets, and a Copier template (`dotfiles-starter`) released with the talk.

### Speaker bio

TODO: ≤ 1000 characters, third person, focused on experience relevant to the talk.

## Premise

I want the same environment wherever I work: at home, at work, or on a temporary machine.
Most dotfiles guides stop at "check them into Git."
This talk starts there and asks what it takes to make that environment portable, reproducible, maintainable, and safe.

The talk should be light-hearted, practical, and honest about what remains unsolved.

## Abstract draft

> I want the same environment wherever I sit: at home, at work, or on a machine I will use for one afternoon. Most dotfiles guides end at "put them in Git." This talk starts there. We will build a portable home-directory setup without superuser access, symlink farms, or runtime templates; then add dependency management, testing, profiling, documentation, and a plan for secrets. Along the way, I will show what a bare Git repository does well, where it gets awkward, and how AI changed the speed at which I discover and iterate on tools. We will go from a fresh container to a configured environment live—and examine the failures that made the process worth testing.

**Abstract policy:** Git is the only named tool.
Name mise, submodules, hooks, CI tools, Bitwarden, age, fnox, and Copier in the detailed session description, slides,
or talk—not in the abstract.
"No third-party requirement" describes the *minimum bootstrap path*, not the fully provisioned environment.

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
- Never export `GIT_DIR` globally.

**Bootstrap idea:** Git can be the installer, with no curl or wget required:
`git clone --bare <url> ~/.local/share/dotfiles`,
then `git --git-dir="$HOME/.local/share/dotfiles" show HEAD:.config/dotfiles/bootstrap.sh | sh`.

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

- Submodules are pinned to commits, which is stronger supply-chain hygiene than plugin managers that pull latest.
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
3. **Dependencies (9–13):** Submodules for third-party source; mise for packages without sudo.
4. **Guardrails (13–19):** Pre-commit checks, CI linting, shell tests, bootstrap tests, and documentation.
5. **Performance (19–24):** Startup used to take seconds; the goal is under one second.
   Show measurements, methodology, and profiling—not an invented before/after number.
6. **Secrets (24–30):** Bitwarden as the source of truth; evaluate the Rust CLI client, age,
   and fnox for retrieval or injection.
   Explain what remains on disk and in the process environment.
7. **Work and home (30–33):** Portable base plus private work overlay.
8. **Fresh-container demo (33–38):** Minimal machine to configured environment;
   run the same steps in CI and keep a recording as backup.
9. **Limitations (38–40):** What the approach cannot cleanly solve.
10. **Takeaway (40–45):** `dotfiles-starter`, a checklist, a link the audience can use, and questions.

Cut candidates if over time: merge the work overlay into limitations; shorten documentation to one slide.

## Testing and profiling

Testing layers:

1. Pre-commit checks catch problems before a commit.
2. CI repeats checks without relying on local hooks.
3. Shell tests (`tests/shell.sh`, `tests/source-cache.sh`) cover startup under supported shells.
4. Integration tests bootstrap in clean, non-root containers (Debian, Alpine/BusyBox, Fedora, macOS runner).
5. Idempotency: run bootstrap twice; `dotfiles status --porcelain` stays empty.
6. The doctor task reports missing or inconsistent setup.
7. Profiling checks whether a correct setup is also pleasant to use.

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
- Test the demo procedure in CI; prepare a recording for unreliable conference networking.
- Never demonstrate with real secrets or work-specific configuration.
- Fix and test the currently recursive bootstrap script before using it on stage.

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
- The actual bootstrap procedure and its idempotency test.
- The current CI checks and what they do *not* cover.
- A scrubbed history excerpt illustrating the vim → Helix iteration.
- Confirmation of the Bitwarden client and work-overlay mechanics.
