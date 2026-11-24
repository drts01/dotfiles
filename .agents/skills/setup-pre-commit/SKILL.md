---
name: setup-pre-commit
description: Set up or improve an existing repository's prek/pre-commit hooks with linter and formatter coverage for every relevant tracked file type, preferring maintained upstream hooks over local hooks and adopting checks without blocking commits on existing debt. Use when configuring .pre-commit-config.yaml or installing repository quality hooks.
metadata:
  origin: Carlos Meza
  version: 0.2.0
---

# Set up pre-commit incrementally

Configure a repository-specific `.pre-commit-config.yaml` compatible with `prek` and standard `pre-commit`
where supported.
Install and verify the active Git hooks.
Treat example tools as candidates, not a fixed checklist.

## 1. Discover the repository

- Inspect Git status first.
  Record tracked changes, staged changes, and untracked files; preserve all existing work.
- Inventory tracked file types, manifests, lockfiles, runtimes, package managers, existing quality configuration,
  CI workflows, and generated or vendored paths.
- Build a coverage matrix for every relevant tracked file type and technology: existing lint, formatting, validation,
  and security checks; gaps; and proposed hooks.
  Identify checks already enforced elsewhere, including project scripts and CI.
  Cover both linting and formatting where suitable tools exist;
  document when one does not apply or no viable tool exists.
- Stop and ask if the repository is not a Git repository or a conflicting existing hook setup makes installation unsafe.

**Done when:** Every relevant file type and technology has an explicit lint/format coverage decision,
and existing rules are accounted for.

## 2. Select and configure tools

- Prefer maintained, well-adopted Rust tools when they provide equivalent coverage;
  otherwise choose suitable maintained compiled or language-native tools.
  Check existing repository tools first,
  then reuse maintained official or established upstream pre-commit hooks wherever possible.
  Use `repo: local` or `language: system` only when no suitable existing hook works,
  or a project-specific command is necessary; explain each exception.
- Fill lint and formatter gaps across the tracked stack: consider `ryl` for YAML, `shfmt` and `shellcheck` for shell,
  `rumdl` for Markdown, `tombi` for TOML, and language-specific tools for code.
  These are candidates, not mandatory picks: verify actual hook repositories, hook IDs, config support, maintenance,
  and runner compatibility before selecting them.
  Avoid duplicate checks that add no meaningful coverage.
- Preserve useful existing rules and workflows.
  Place behavioral settings in each tool's supported configuration file, not duplicated in hook `args`.
  Put settings in `pyproject.toml` only if that tool actually reads those settings there;
  otherwise use its supported file.
- Pin external hooks to verified revisions; use commit SHAs where immutable resolution is required.
  For justified local/system hooks, check executable availability and document the required installation
  for contributors and CI.
- Put inexpensive checks on `pre-commit` and appropriate heavier checks on `pre-push`.
  Configure `default_install_hook_types: [pre-commit, pre-push]` when both stages are active.
  Treat a 2–3-second pre-commit run as a measured goal, not a promise.

**Done when:** The configuration parses, upstream hooks are used where suitable, hook IDs and revisions are verified,
the coverage matrix has no unexplained lint/format gaps,
and direct tool invocations use the same behavioral settings as hook invocations.

## 3. Audit safely and adopt incrementally

- Test **each** proposed hook against applicable tracked files at its intended stage.
  Test `pre-push` separately: a default `run --all-files` does not prove pre-push passes.
  Inspect both exit status and file changes.
- Run potentially mutating all-files checks in an isolated copy containing the current repository state,
  including existing user changes.
  If that is not feasible, request approval before running them on the working tree.
  Protect user changes; never use broad Git rollback to clean up hook output.
- Keep a hook active only when it passes without introducing an unapproved commit/push blocker or broad rewrite.
  A small expected auto-fix is not automatically grounds for quarantine;
  assess its effect and obtain approval if disruptive.
- Move checks blocked by existing debt or broad modifications to `stages: [manual]`.
  Add a nearby comment recording the intended stage and specific reason,
  for example `stages: [manual] # target-stage: pre-commit; reformats legacy files`.
- Verify quarantined hooks at the **manual** stage using a tested per-hook command.
  Record the exact failures and the condition for promotion.
  Preserve real findings rather than weakening rules to manufacture a pass.

**Done when:** Every hook is either verified active at its intended stage
or explicitly quarantined with a reproducible manual invocation and promotion criterion.

## 4. Install, document, and hand off

- Re-run the final active `pre-commit` and `pre-push` stages against applicable files.
  Verify representative tools directly without duplicating behavioral flags.
  Install both active hook stages using the available compatible runner; check that installation succeeded.
- Update the existing `CONTRIBUTING.md` or `README.md` with runner setup, active-stage commands,
  tested manual-hook commands, and promotion instructions.
- Report the coverage matrix, files changed, commands actually run, active hooks by stage, justified local/system hooks,
  quarantined hooks with reason and exact manual command, pre-existing failures, measured runtime if obtained,
  and anything unverified.
  If dependencies, network access, Git context, or the runner prevent verification,
  report the blocker and remaining commands instead of claiming success.
- Do not commit changes unless the user explicitly requests a commit.

**Done when:** Active stages pass without unapproved broad edits, the hooks are installed where possible,
current user changes remain intact, and the handoff distinguishes verified results from blocked checks.
