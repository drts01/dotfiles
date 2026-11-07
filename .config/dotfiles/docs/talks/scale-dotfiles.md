# SCaLE talk notes: production-grade `$HOME`

## Working title

**Production-Grade `$HOME`: Tested, Sudo-Free Dotfiles with Only Git and a Shell**

Alternative: **`$HOME` in Production: Tested, Sudo-Free Dotfiles with Only Git and a Shell**

"Only" turns the minimal dependency set into a constraint; without it, "with Git" reads as a truism.

Use `$HOME`, not `HOME_DIR`; `$HOME` is the standard variable the audience recognizes.
Hyphenate "Production-Grade" (compound modifier).
Do not use "The Missing Manual" in the title or abstracts: O'Reilly Media, Inc. holds the registered trademark.
Drop "the DevOps Way": it reads as a buzzword and does not state the differentiator (tested, sudo-free).

## SCaLE 24x call for proposals

Source: the call for proposals (CFP) page, <https://www.socallinuxexpo.org/scale/24x/cfp> (retrieved 2026-10-26).

- Conference: April 1–4, 2027, Pasadena Convention Center.
- **Submission deadline: November 1, 2026.**
  Notifications begin December 1, 2026.
- Session slot: about **45 minutes**.
- Speakers must present in person; travel is not funded; speakers receive a full conference pass.
- Required fields: title, **short abstract** (print), **long abstract** (online), speaker profile with photo, bio
  (**≤ 1000 characters, third person**), track, level, optional message to reviewers.
- Provided setup: hands-free microphone, handheld microphone, projector with HDMI.
- Slides must be in an open, non-proprietary format.
- No sales pitches.
- A speaker may submit more than one proposal.
- Notices come from `cfp@socallinuxexpo.org`; add it to contacts to avoid corporate spam filtering.

**Recommended track:** Developers, Platform Engineering & DevEx
(the topic explicitly lists local development environments and CLIs).
Alternatives: Systems & Infrastructure (configuration management) or the co-located DevOpsDayLA.

## Tasks (ordered by priority)

### P0: required before submitting (deadline 2026-11-01; target 2026-10-30)

- [x] Confirm in-person availability for April 1–4, 2027, and self-funded travel.
- [x] Confirm the employer's policy on public speaking and on the public dotfiles content.
- [x] Create or log in to the SCaLE CFP account; add `cfp@socallinuxexpo.org` to contacts.
- [x] Select the final title.
- [x] Complete the short abstract and long abstract (drafts below).
- [ ] Re-verify the "19 vs. 7 tool directories" count with a script before using it on a slide
      (removed from the abstract).
- [x] Write the speaker bio (≤ 1000 characters, third person); see [Speaker bio](#speaker-bio).
- [ ] Select a photo.
- [ ] Select track and level: Developers, Platform Engineering & DevEx; Intermediate.
- [ ] Complete the message to reviewers (draft below).
      Fill in the `dotfiles-starter` license and a prior SCaLE talk recording URL;
      set the CI sentence to the jobs that are green at submission.
- [ ] Push the bootstrap fixes and confirm a green `Bootstrap` CI run for every matrix job;
      the reviewer message claims the workflow exists.
- [ ] Fix the red CI jobs, or remove their claims from the reviewer message.
      Run `41344118730` (2026-11-01): `Shell`, `Bootstrap (debian|alpine|ubuntu)` pass.
      `Lint` fails on a formatter diff (`AlertError` alignment); `Bootstrap (fedora)` failed because `cmp` is missing
      (`tests/bootstrap.sh` line 169; image lacks `diffutils`);
      fixed locally by replacing `cmp -s` with `git diff --no-index --quiet`, pending a green CI run;
      `Bootstrap (chainguard)` fails with `repo is not bare`
      (`fatal: error reading '/home/git/.git'`); `Bootstrap (macos)` fails with `Git exclude points to the wrong file`.
- [x] Guard submodule `source` calls in `999_zsh.zshrc`; add the Zsh absence test to `tests/shell.sh`.
- [ ] Submit.

### P1: before submitting if the proposal links the repository; otherwise before acceptance

- [x] Fix `.config/dotfiles/bootstrap.sh`: it downloaded and executed itself
      (infinite recursion), and it inverted the `SKIP_MISE_INSTALL` condition.
      The README install command uses this script.
      The entrypoint now fetches `mise-tasks/bootstrap.sh`, and mise is optional.
- [x] Remove employer references from the public repository
      (`.ssh/config.d/everbridge##everbridge`, `git/UHG/.gitconfig`).
      Employer clearance is complete and the employers are already public, so history does not need rewriting.
- [x] Resolve the `##Darwin` / `##everbridge` yadm-style file names, which conflict with the "no templating" message.

### P2: after submission, before notification (2026-12-01)

- [ ] Capture a reproducible shell-startup baseline from an old commit before further optimization.
- [x] Add a GitHub Actions workflow that bootstraps in a fresh non-root container
      and runs bootstrap twice (idempotency).
      This workflow is also the demo fallback.
      Done: the `bootstrap` job in `.github/workflows/ci.yaml` runs one parallel job per image plus a macOS host job;
      `mise run bootstrap:test:container` runs the same script locally.
- [ ] Inventory the checks that hooks and CI enforce.

### P3: after acceptance, before the talk

- [ ] Decide the secrets workflow; mise is the integration point.
      Choose the resolver (Bitwarden Rust client `rbw` or `bws`, age, fnox) and the mise mechanism
      (see [Secrets questions to resolve](#secrets-questions-to-resolve)).
- [ ] Document the work-overlay mechanics without employer-sensitive details.
- [ ] Build and test the `dotfiles-starter` Copier template.
- [ ] Build the [maturity model](#dotfiles-maturity-model) slide and the audience checklist.
- [x] Add an absence test: start Zsh with submodules uninitialized and mise absent; startup must be silent and exit 0.
      The test skips Bash: it sources no submodule files and writes job-control noise to stderr without a TTY.
- [ ] Script the fresh-container demo from the same steps as the GitHub Actions workflow.
      `tests/bootstrap-container.sh` already runs locally and in CI;
      the stage demo still needs a visible user-facing install, not only the test output.
- [ ] Save the latest passing workflow run offline
      (screenshots or downloaded logs); the fallback must work without conference Wi-Fi.
- [ ] Decide whether the Zed limitation stays unresolved or receives a tested mitigation.
- [ ] Test home-manager under `nix-portable` in non-root Debian and Ubuntu 24.04 containers.
      Activate a minimal config, then open a fresh login shell outside `nix-portable`.
      Record whether `~/.zshrc` resolves and how long the first activation takes.
      Replace the "verify" caveats in [Rootless Nix and home-manager](#rootless-nix-and-home-manager) with the result.
- [ ] Write slides in an open format; fit them to 45 minutes.
- [ ] Rehearse with a timer; dry run at a local meetup or user group if possible.
- [ ] Re-verify all repository statistics shortly before the talk.

## Submission drafts

### Short abstract (print)

Do your dotfiles pass validation tests?
Do they deploy?
This talk treats $HOME as a small production system.
The setup bootstraps with only Git and a POSIX shell: no sudo, symlinks, or templating.
Clean Linux containers test installs as a non-root user and check that the shell starts when tools are missing.
The repository stores references to secrets, not secret values.
Watch a fresh container become a working shell in the live demo.

### Long abstract (online)

Keeping dotfiles in Git solves storage, not deployment.
A passing lint check proves the files parse.
It doesn't prove that a fresh machine without sudo ends up with a working shell,
or that uninstalling a tool leaves startup clean.
My dotfiles passed every lint check while hiding bugs that only appeared on deployment.
An installer re-downloaded itself forever, a shell errored when a plugin was missing,
and every new shell started with a failing exit status and no error.

AI-assisted tinkering made trying a new editor or terminal an afternoon's work.
I now add and remove tools in $HOME faster than my setup can handle, often on machines I don't control.

This talk picks up where the popular bare-Git-repository dotfiles tutorial stops.
The base needs only Git and POSIX sh; everything else is an optional layer.
You will learn how to:

- Use Git as the installer: no sudo, no symlink farm, no runtime templating, no new configuration language,
  and a bootstrap that is safe to run twice.
- Pin plugins with Git submodules and install optional user-space tools with mise,
  then prove Zsh still starts with no errors and exit status 0 when optional components are not available.
- Test deployment, not only syntax: install as a non-root user in clean Debian (dash), Alpine
  (BusyBox sh), and Fedora (Bash) containers in CI.
  Run the same matrix locally with Podman or Docker.
- Layer a private work repository over a public personal base, with both sharing $HOME as their working tree.
- Keep secrets out of a public repository: commit references instead of values.

Each deployment-only bug appears with the line that failed and the test that caught it.
The live demo takes a fresh container to a working shell using the same steps CI runs.
You'll also see the problems I haven't solved, and when GNU Stow, chezmoi, yadm, vcsh,
or Nix home-manager is the better choice.
You'll leave with a five-level maturity model for rating your own setup
and an open-source starter template you can use the same day.

For developers, site reliability engineers, and anyone who works across personal, work, and temporary machines.
Assumes comfort with Git and a Unix shell; no Nix, Ansible, or dotfiles-manager experience needed.

**Abstract policy:** The short abstract names only Git and POSIX sh.
The long abstract names open-source projects and Linux distributions: reviewers score open-source relevance,
and naming the comparison set signals depth and fairness.
Frame mise and submodules as optional; "only Git and a shell" describes the *minimal bootstrap path*,
not the fully provisioned environment.
AI is the motivation, not the subject; keep it to one sentence and never open with it.
The AI sentence must stay concrete (what got cheaper); "faster than ever" without a cause reads as filler.
The absence-test bullet names Zsh: `tests/shell.sh` covers Zsh only,
so "the shell" would claim more than the test covers.
The secrets bullet frames "secret zero" as a problem, not a solved bootstrap;
the limitations slide states that bootstrap cannot make credentials appear on an untrusted machine.
The work-overlay bullet does not promise enforced path exclusivity until the docs describe the mechanism (P3).
The secrets bullet promises a tool-agnostic pattern rather than a specific tool or a solved bootstrap:
references instead of values, use-time resolution, and "secret zero."
On stage, mise is the integration point.
Keep "AI agents inherit the shell environment" for the slides: mise `[env]` still exports to every shell in the project,
so the abstract cannot promise agent isolation.
Do not state how people currently test their dotfiles; no data exists, and any prevalence claim invites challenge.
The gap is deployment and removal testing, not testing in general; the installer bug is one example, not the lead.
CFP matrix claims: Debian (dash), Alpine (BusyBox sh), Fedora (Bash).
Debian, not Ubuntu: both use dash as `/bin/sh`, and the Debian container is the minimal non-root case
(the Ubuntu runner job has passwordless sudo).
Omit Wolfi/Chainguard and macOS until their jobs are green; add them to the slides, not the CFP.
Keep rootless Nix out of the abstract until the container test (P3) verifies it.

### Message to reviewers (draft)

> Repository: https://github.com/drts01/dotfiles (public since 2019).
>
> CI runs linting, Zsh startup tests (including startup with submodules and mise absent), and a deployment test.
> The deployment test installs the dotfiles as a non-root user in fresh containers, then runs again to check
> idempotency. At submission, the Debian, Alpine, and Fedora container jobs pass. The live demo runs the same steps as
> CI, and a saved passing run is the offline fallback if conference networking fails. Standard HDMI is enough.
>
> Outline (45 min): problem and prior art (9), dependencies (4), guardrails and the deployment-only bug table (8),
> secrets pattern (5), work overlay (3), live demo (7), limitations (3), maturity model and starter template (3),
> Q&A (3).
>
> The talk positions the approach against the Atlassian bare-repository tutorial, GNU Stow, chezmoi, yadm, vcsh, and
> Nix home-manager, including where each is the better choice. AI is a one-sentence motivation, not the subject.
> Everything covered is open source: Git submodules, mise, prek, a POSIX shell test matrix, a tool-agnostic secrets
> pattern, and dotfiles-starter. The starter is a Copier template released under [LICENSE] with the talk. Copier runs
> once at creation; the deployed dotfiles need no templating. Slides will be in an open format. No product pitch.
>
> Previous SCaLE talk recording: [URL]

Present tense is valid only for CI jobs that are green at submission
(see the P0 CI item); remove or reword claims for red jobs.
If Fedora is still red at submission, use: "At submission, the Debian and Alpine container jobs pass;
a fix for the Fedora job is in progress."
Keep Fedora in the long abstract either way: it describes talk content, not current CI state.
Replace `[LICENSE]` and `[URL]` before submitting; do not submit placeholders.

### Speaker bio

Source: `~/git/tmp/CFP-pinned-but-mutable/presentation/scale-24x-speaker-bios.md`
(Variant 1 + formal dotfiles hook, with "profiled" replaced by "reproducible").
Plain text for the CFP form; 788 characters.

> Carlos Meza is a Senior Software Engineer at UnitedHealthcare, where he works on CI/CD, platform automation, and
> developer experience on AWS. He found his way into tech through Linux user groups, local meetups, and SCaLE. His
> ten-plus years include engineering roles at Verizon, Everbridge, and The Walt Disney Studios. At Disney, he designed
> and built a Policy-as-Code service that enforced cloud compliance automatically. He chaired DevOpsDays LA, served on
> the Interop network operations center (NOC) team, and now leads a team on the SCaLE A/V crew. He has spoken at SCaLE
> five times since SCaLE 14x. He has kept his dotfiles in a public Git repository since 2019 and treats $HOME like a
> small production system: versioned, tested, and reproducible. GitHub: drts01 · LinkedIn: cmeza99

## Premise

I want the same environment wherever I work: at home, at work, or on a temporary machine.
Most dotfiles guides stop at "check them into Git."
This talk starts there and asks what it takes to make that environment portable, reproducible, maintainable, and safe.

The talk should be light-hearted, practical, and honest about what remains unsolved.

## Audience takeaway

A decision framework and a working starting point for managing `$HOME`:

1. Start with Git and a shell, without sudo.
2. Make optional tooling additive rather than a prerequisite for using the dotfiles.
3. Make removal as safe as installation: a missing tool must not break startup.
4. Test deployment, not only configuration syntax.
5. Keep secrets out of the public repository.
6. Know when a bare-repo approach is the wrong fit.

Close with the [maturity model](#dotfiles-maturity-model) so attendees can rate their own setup and pick one next step.

Publish a **`dotfiles-starter` Copier template**.
Copier generates a starter repository once;
the resulting dotfiles do not require runtime templating or Copier to deploy.

## Narrative

**Cold open (audience poll):** Ask in sequence and let the hands drop:
"Who keeps dotfiles in Git?" → "Who has bootstrapped them on a new machine this year?" → "Who has ever *tested*
that bootstrap?" → "On a machine without sudo?"
The drop-off states the talk's premise in 30 seconds.

**Opening problem:** "I want to sit down anywhere and feel at home."

**Then:** I could spend months tuning a `vimrc`.

**Now:** AI is the catalyst: it makes discovering, evaluating, and iterating on new tools much faster.
AI is the motivation for the talk, not its subject; do not spend more than the opening on it.
Faster evaluation means tools arrive *and leave* faster; the dotfiles must survive both.
First-add dates under `.config/`: 7 tool directories in 2021–2025; 19 from April to October 2026
(editors: vim, Helix, Zed; terminals: Alacritty, Rio).
Re-verify with a scripted count; directory moves and top-level files skew it.
I can produce a useful Helix configuration in minutes, but the keybindings still need verification.
The repository had 5 commits in 2025 and 223 in 2026 as of 2026-10-26.
Do not equate commit count with quality; use it to illustrate a changed iteration speed.

**Central tension:** When trying a new tool becomes cheap, how do I keep `$HOME` trustworthy on every machine?

**Answer:** Treat `$HOME` like a small production system: provision it, pin dependencies, test it, profile it,
document it, and protect its secrets.

**Closing callback:** The bootstrap process should be demonstrably repeatable, not merely a command in a README.
Resolve the bootstrap bug introduced in the opening before the live demonstration.

**Closing line candidate:** "AI made trying tools cheap.
The guardrails make it safe to keep them, or to drop them."

### Repository evidence for gags

Re-verify before the talk; the numbers date from 2026-10-26.

- Commits per year: 2019: 4, 2021: 10, 2022: 33, 2023: 23, 2024: 18, 2025: 5, 2026: 223 (316 total).
- `fix(zsh)` 39 commits versus `feat(zsh)` 26.
- Helix, 2026-09-29/30: `add config` → `correct key bindings` → `correct status line` → `update configuration` →
  `remove keybindings`; Zed configuration arrived the next day.
- Zed, 2026-10-23: `add and harden terminal allow list`, followed by three `more permissive` commits.
- `.config/zed/AGENTS.md` and Cline rules: instructions for AI agents are version-controlled dotfiles.
- `.typos.toml` exists, yet the README said "Borne Shell" until commit `485bcc7`,
  and commit messages contain `grammer` and `managment`. <!-- # typos: ignore -->
- Submodule commits: 15 across `fix(submodules)`, `fix(submodule)`, and `feat(submodules)`.
- Cold open: the bootstrap script downloads and executes itself (`curl | sh | curl | sh …`).
- Writing the bootstrap test exposed five bugs besides the recursion;
  see [Bugs only deployment tests find](#bugs-only-deployment-tests-find).
  Use them as evidence for "test deployment, not syntax."
- The Atlassian tutorial's own conflict-backup one-liner parses `git checkout` output with `egrep`:
  the same class of fragile parser that broke here.
- A corporate network blocked or intercepted three of four test images' sources
  (Alpine CDN, `deb.debian.org`, `cgr.dev` blob storage); the test runner gained mirror overrides.
- Audience participation: "Raise your hand if your dotfiles have a commit message that says only 'update'."
  (This repository has `Update config` twice on 2021-10-01.)

## Constraints and architecture

- No sudo for the portable path.
- Only Git and a shell required to get started.
- No new tool-specific knowledge: no configuration language or manager to learn;
  leaving the approach means deleting one alias, and the files stay where they are.
- No runtime templating.
- Integrations compose through each tool's own config and shell hooks
  (mise activation, Bitwarden CLI), not through a dotfiles manager's plugin layer.
- Prefer real files in `$HOME` over symlink deployment.
- Personal dotfiles are the portable base.
- Work-specific files live in a separate, private repository.
- mise manages packages and optional tools after the minimal setup is usable.
- Submodules pin third-party source such as plugins and themes; they are not a general binary package manager.

### Why a bare repository

The home directory is the working tree: edit files where applications use them,
then use Git to review and commit changes.
Changes need no separate deploy or relink step.

Give symlink managers and templating systems a fair comparison.
The advantage is a small bootstrap surface; the cost is weaker support for host-specific configuration,
especially formats without includes or overrides.
Do not claim a bare repository is universally best.

| Approach            | Examples         | New knowledge required       | Strength                                              | Cost                                                                      |
| ------------------- | ---------------- | ---------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------- |
| Bare repository     | This talk        | Git, POSIX shell             | Git and shell are enough; no relink or render step    | `$HOME` is a hazardous working tree; host differences harder              |
| Split bare repos    | vcsh + myrepos   | Git + vcsh                   | Prior art for the work overlay                        | Another tool for what two Git aliases do                                  |
| Symlink manager     | GNU Stow         | Stow package layout          | Repository and home directory stay separate           | Link creation and maintenance become deployment steps                     |
| Templating manager  | chezmoi, yadm    | Template syntax, manager CLI | Strong host-specific config; built-in secret managers | Another dependency; source and target can drift                           |
| Declarative         | Nix home-manager | Nix language, store, flakes  | Packages and config together; atomic rollback         | Steep learning curve; installing Nix normally needs root to create `/nix` |

The "new knowledge" column is the core argument: everything here is Git and shell, which the audience already knows.
Be precise: the bare-repo gotchas below are still knowledge, but *Git* knowledge that transfers everywhere,
not knowledge of a tool its maintainers may abandon.
Do not claim integration with mise or Bitwarden is unique; chezmoi integrates with Bitwarden natively.
Claim instead that integrations need no adapter: each tool reads its own configuration files.

### Prior art to credit

- **Atlassian tutorial** (<https://www.atlassian.com/git/tutorials/dotfiles>),
  from `StreakyCobra`'s Hacker News comment:
  the canonical bare-repository setup and likely the audience's starting point.
  Frame the talk as its missing manual
  (spoken framing only; "The Missing Manual" is an O'Reilly trademark, so keep it off titles and slides):
  - Installs with `curl -Lks … | /bin/bash`; `-k` disables TLS verification.
  - Depends on a third-party URL shortener and a Bitbucket snippet; verify whether they still resolve.
  - Backs up conflicts by parsing `git checkout` output with `egrep`.
  - No fetch refspec, no idempotency, no tests ("tested on many freshly minted Alpine Linux containers" by hand).
  - Unquoted `$@` in the `config` function.
- **Nix home-manager:** the strongest answer to "treat `$HOME` like production."
  Acknowledge that it handles atomic, declarative environments better.
  This approach targets a different constraint: a machine without root, used for an afternoon,
  by someone who should not have to learn a new language first.
  Rootless Nix exists but does not deliver a usable home-manager `$HOME`;
  see [Rootless Nix and home-manager](#rootless-nix-and-home-manager).

Expected question: "Why not Nix?"
Answer: different constraints; if you control the machine and want rollback, use home-manager;
if you need Git-and-shell-only on a box you don't own, use this.

Follow-up question: "What about nix-portable?"
Answer below.

### Rootless Nix and home-manager

Short answer: rootless Nix runs packages, but home-manager's output only resolves inside the Nix sandbox,
so the login shell and GUI apps outside it see broken links.

| Option                                  | Mechanism                                                                       | home-manager result                                                                                                                            |
| --------------------------------------- | ------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `nix-portable`                          | `bwrap`, `proot`, or Nix namespaces map `~/.nix-portable/store` to `/nix/store` | Not usable for `$HOME`: README states programs outside cannot call nix-portable programs; `nix-env` profiles unsupported; Linux only, no macOS |
| `nix-user-chroot` / `nix --store ~/nix` | User namespace bind-mounts `/nix`                                               | Works only inside the namespace; the login shell must re-exec into it                                                                          |
| Nix built with a custom store path      | Store at a custom path such as `~/nix/store`                                    | Works natively, but cache.nixos.org binaries assume `/nix/store`; everything builds from source (hours)                                        |

Why home-manager breaks outside the namespace (verify each in a container before stating on stage):

- `home.file` entries are symlinks into `/nix/store`; outside the namespace, `~/.zshrc` dangles.
- Standalone home-manager installs `home.packages` into a Nix profile; nix-portable does not support `nix-env` profiles.
- The terminal emulator, `sshd`, and the display manager start outside the namespace.
- Ubuntu 24.04 restricts unprivileged user namespaces via AppArmor; nix-portable then falls back to `proot`,
  which its README warns can add significant overhead.
- macOS has no rootless option; nix-portable is Linux-only.

Slide wording: "Rootless Nix runs programs.
It does not give you a home directory."
Do not claim home-manager is impossible without root; claim it does not meet the constraint
(Git and a shell, any login path, an afternoon).

Source: <https://github.com/DavHau/nix-portable> (Drawbacks and Missing Features sections, retrieved 2026-10-31).

Without templating, put host differences where formats already support them: Git `includeIf`, ssh `Include` and `Match`,
shell `.d/` directories and `uname` conditionals, Alacritty `import`, and untracked local override files.

Bare-repository gotchas worth a slide:

- Set `status.showUntrackedFiles no`.
- A bare clone has no `remote.origin.fetch` refspec; set it, or `git fetch` does not update remote-tracking branches.
- A bare repository has no index until the first checkout; key "already installed" on the index, not the directory.
- `git submodule` requires the current directory to be inside the work tree, even with `--work-tree`.
- Never export `GIT_DIR` globally.

**Bootstrap idea:** Git can be the installer, with no curl or wget required
(documented in the README):
`git clone --bare --single-branch --depth=1 <url> ~/.local/share/dotfiles`,
then `sh -c "$(git --git-dir="$HOME/.local/share/dotfiles" show HEAD:.config/dotfiles/mise-tasks/bootstrap.sh)"`.
The bootstrap test covers this path.

### Work overlay

The work repository contains work-specific configuration, including `mise.local.toml` and extra shell startup files.
Explain how the repositories avoid tracking the same path.
Treat the second repository as both a useful boundary and a real operational cost.

Model: the personal base defines extension points; the private work repository fills them
(like a base image plus layers).
Both share `$HOME` as the working tree with separate Git directories.
Neither repository may track a file the other tracks.

### Dependencies

- Submodules keep as much as possible managed through Git alone: one tool to clone, pin, review, and update.
  Pinning to a commit is a side benefit; do not claim it beats plugin managers: lazy.nvim, for example, has a lockfile.
  Explain initialization, detached `HEAD` state, and updates.
- mise installs packages into the user's home without sudo; discuss lockfiles where they apply.
- Verify which dependency types Renovate updates before claiming it on a slide.
- Modern tools (`bat`, `eza`, `atuin`) are examples, not the subject.
  Show graceful fallback on a minimal machine.
- A guard (`command -v`, file existence) wraps every integration,
  so removing a tool or skipping submodules never breaks startup.
  The `Shell` CI job passed only because it checked out submodules; `999_zsh.zshrc` sourced submodule files unguarded.
  The Zsh absence test in `tests/shell.sh` reproduced it and now guards against regression.
  The same test found a second bug: `[[ -n $ZSH_PROFILE ]] && zprof`
  as the last line of `.zshrc` made every interactive Zsh session start with `$?` = 1.

## Proposed full-session flow

Fit to a 45-minute slot; times are targets.

1. **The problem and the `vimrc` gag (0–4):** Same environment everywhere; AI changed how fast I can experiment.
2. **Git is the beginning, not the end (4–9):** Start from the Atlassian tutorial and show what it leaves out.
   Compare Stow, chezmoi/yadm, vcsh, and Nix home-manager; make the "new knowledge required" argument.
3. **Dependencies (9–13):** Submodules keep third-party source in Git; mise for packages without sudo.
4. **Guardrails (13–21):** Pre-commit checks, CI linting, shell tests, bootstrap tests, absence tests.
   Centerpiece: [Bugs only deployment tests find](#bugs-only-deployment-tests-find).
   One slide on startup time: a single measured before/after and the tool used; skip detailed profiling.
5. **Secrets (21–27):** Bitwarden as the source of truth; compare the Rust CLI client, age,
   and fnox for retrieval or injection.
   Explain what remains on disk and in the process environment.
6. **Work and home (27–30):** Portable base plus private work overlay.
7. **Fresh-container demo (30–37):** Minimal machine to configured environment;
   the GitHub Actions workflow runs the same steps, and a saved run is the offline fallback.
8. **Limitations (37–40):** What the approach cannot cleanly solve.
9. **Takeaway (40–45):** Maturity model self-assessment, `dotfiles-starter`, a link the audience can use, and questions.

Cut candidates if over time: merge the work overlay into limitations; shorten documentation to one slide.

## Testing and profiling

Testing layers:

1. Pre-commit checks catch problems before a commit.
2. CI repeats checks without relying on local hooks.
3. Shell tests (`tests/shell.sh`, `tests/source-cache.sh`) cover startup under supported shells.
4. Integration tests (`tests/bootstrap.sh`) bootstrap without mise in clean, non-root containers: Debian (dash), Alpine
   (BusyBox `sh`), Fedora (Bash), Chainguard/Wolfi (dash, wget-only), plus a macOS runner.
   Each image is a parallel CI job; `tests/bootstrap-container.sh` runs the same matrix locally with Podman or Docker.
5. Idempotency: run bootstrap twice; the `$HOME` file list and `HEAD` stay unchanged
   and `dotfiles status --porcelain` stays empty.
   Upstream commits fast-forward.
6. The doctor task reports missing or inconsistent setup.
7. Absence: start Zsh with submodules uninitialized and mise missing; startup is silent and exits 0 (`tests/shell.sh`).
   Proves removal is as safe as installation.
8. Profiling checks whether a correct setup is also pleasant to use (supporting point; one slide).

**Slide idea:** "The demo is a CI job."

Profiling tools:

- `bench/shell-startup.sh` (`hyperfine`, isolated home): startup-to-exit wall time.
- `zsh-bench`: perceived first-prompt and input lag.
- `zmodload zsh/zprof`: per-function time.
- `zsh -x` with a timestamped `PS4`; `bash -x` with `EPOCHREALTIME` (Bash 5+; macOS ships Bash 3.2).
- `git bisect run` with a time threshold to find regressions.

Baseline capture: create a worktree at an old commit, copy the current bench script into it, and run it there;
the script derives its root from its own location.

## Bugs only deployment tests find

Centerpiece of the Guardrails segment: one slide per bug, each with the line that failed and the test that caught it.
Every item passed linting.

| Bug                                         | Symptom                                     | Caught by                       |
| ------------------------------------------- | ------------------------------------------- | ------------------------------- |
| Bootstrap downloads and runs itself         | `curl \| sh` recursion, never finishes      | Bootstrap test                  |
| Inverted `SKIP_MISE_INSTALL`                | Installs mise only when told to skip        | Bootstrap test without mise     |
| `read` strips Git's leading tab             | Conflict-backup parser never matches        | Bootstrap over existing files   |
| Bare clone lacks a fetch refspec            | Tracking branches misbehave on update       | Idempotency (second run)        |
| Detached HEAD under `set -e`                | Bootstrap aborts mid-run                    | Bootstrap test                  |
| `git submodule` outside the work tree       | Fails despite `--work-tree`                 | Bootstrap test                  |
| Unguarded `source` of submodule files       | Zsh startup errors without submodules       | Absence test (`tests/shell.sh`) |
| `[[ -n $ZSH_PROFILE ]] && zprof` last line  | Every Zsh session starts with `$?` = 1      | Absence test (exit status)      |
| Corporate TLS interception, blocked mirrors | Three of four images fail on a work network | Local container matrix          |

Open the segment with the Atlassian tutorial's `egrep` backup parser:
this repository inherited the fragile pattern rather than inventing it.

## Dotfiles maturity model

Closing self-assessment.
Ask the audience to pick their level and one step to the next.

| Level | Name       | Criteria                                                                            |
| ----- | ---------- | ----------------------------------------------------------------------------------- |
| 0     | Scattered  | Config lives only on the machine                                                    |
| 1     | Versioned  | Config is in Git                                                                    |
| 2     | Deployable | One documented command bootstraps a new machine without sudo                        |
| 3     | Tested     | Bootstrap runs in a clean container; second run is a no-op; missing tools are safe  |
| 4     | Operated   | CI matrix across OSes and shells; pinned dependencies; secrets policy; work overlay |

Keep the criteria observable (a command or a CI job proves each), not aspirational.
The Atlassian tutorial lands at level 2 by hand; the cold-open poll questions map to levels 1–3.

## Demo and verification plan

- Use a non-root account in a fresh container.
- Separate **minimal bootstrap** (Git and shell) from **optional provisioning** (mise and managed tools).
  Show the elapsed time for each.
- Run the bootstrap twice and check that the second run is safe.
- Run shell tests and the repository's doctor task.
- Profile shell startup with the existing `bench/shell-startup.sh`.
- Run the demo procedure in the GitHub Actions container workflow; save a passing run offline
  (screenshots or downloaded logs) as the fallback for unreliable conference networking.
- Never use real secrets or work-specific configuration in the demo.
- Rehearse the demo against the pushed `trunk` entrypoint, not a working-tree copy; the test uses `RAW_URL=file://…`,
  the audience uses `raw.githubusercontent.com`.

## Secrets questions to resolve

- Confirm which Bitwarden Rust CLI client to use and how it handles local vault data.
- Decide whether age, fnox, or both solve a concrete problem here; avoid adding them solely to fill a slide.
- mise mechanisms (<https://mise.jdx.dev/templates.html>, retrieved 2026-11-01):
  - `[env]` with `exec(command=...)`: resolves when the config renders and exports to every shell in the project,
    including AI agents started there.
    `exec()` runs on every render; `cache_key`/`cache_duration` avoid repeated vault calls
    but write the plaintext output under `MISE_CACHE_DIR`.
  - Task `env` with `{{ secrets.NAME }}`: rendered when the task starts and granted only to that task.
    Narrowest scope, but experimental (`experimental = true`); re-verify before the talk.
  - Both need a trusted config and fail under `MISE_SAFE=1`.
- Decide what a temporary machine's environment, files, and shell history may contain.
- Keep private keys and plaintext secrets out of the public dotfiles repository.
- Explain "secret zero": a fresh machine still needs a trusted way to authenticate.
- Rotate a committed secret; deleting it in a later commit is insufficient.
- AI agents running in a terminal inherit its environment; prefer project-scoped secrets over global exports.
- Prefer per-machine or hardware-backed SSH keys over syncing private keys.
- Demo with fake credentials only; for example, a pre-commit hook blocking a fake key.

## Limitations slide

- Zed rewrites its single `settings.json`,
  making Git diffs noisy and environment-specific settings difficult without templating
  or application-supported overrides.
- Work requires a second dotfiles repository and a separate provisioning step.
- A bare repository makes `$HOME` the working tree; broad `git clean`, `git add .`, or destructive resets are hazardous.
- Formats without includes or overrides cannot layer.
- Submodules and optional tools add update and network costs.
- Bootstrap cannot make credentials appear on an untrusted machine.
- Linux and macOS differ; test portability rather than assume it.
- Restricted networks (TLS interception, blocked mirrors or registries) can break a bootstrap that passes in CI.
- No sudo has a boundary: system packages and `/etc` are out of scope,
  and `chsh` to a user-installed shell fails because `/etc/shells` does not list it.
- No atomic rollback of packages and config together; Nix home-manager does this better where Nix is available.

Leave the Zed issue visibly unresolved if no reliable solution exists.
The issue is an honest example of where the chosen architecture strains.

## `dotfiles-starter` scope

Keep the first version small: bare-repo bootstrap, a minimal shell configuration, optional mise integration,
an extension point for private overrides, tests, CI, documentation, and a safe secrets policy.
Copier is a **creation-time convenience**, not a deployment dependency of the generated repository.

Notes:

- Store the answers file under `.config/dotfiles/` rather than at the `$HOME` root.
- `copier update` expects a regular working copy; run updates in a normal clone, not the bare-repository `$HOME`.
- Expect the audience question "You said no templating"; answer: templates run once at creation, never at deploy.

## Evidence to collect before writing slides

- Reproducible old and current shell-startup measurements that record the machine and the method.
- A passing `Bootstrap` CI run (all matrix jobs) saved offline; the procedure and idempotency test exist.
- The current CI checks and what they do *not* cover
  (for example, the bootstrap test runs without mise, so CI does not test `update` or `mise bootstrap`).
- A scrubbed history excerpt illustrating the vim → Helix iteration.
- Confirmation of the Bitwarden client and work-overlay mechanics.
