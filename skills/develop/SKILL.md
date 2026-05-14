---
name: develop
description: "Autopilot feature delivery: spec, implement, commit, review — stops for manual testing before merge."
---

# Develop

Deliver a feature end-to-end with minimal human intervention.

## Input

`/develop <description>` — a plain-English feature description or slug name.

If no description is provided:
1. Read `docs/wip/feature_backlog.md` if it exists.
2. Pick the first `## NNN — title` item (lowest `NNN`).
3. Announce: "Next up: **NNN — title** — description. Starting now." then proceed.
4. If no backlog exists, ask: "What should I build?" and wait.

## Resuming an interrupted run

1. Run `git log --oneline` to see commits on the branch.
2. Check `Status` in `docs/wip/features/<NNN-slug>.md`.
3. Skip completed phases, continue from the next one.

## Phase 0 — Setup

1. Derive a slug from the description (e.g. `user-auth`, `csv-export`).
2. Find the highest `NNN` in `docs/wip/features/` matching `[0-9][0-9][0-9]-*.md` and use one higher (start at `001` if empty). Use the full `NNN-<slug>` everywhere: branch (`feat/NNN-<slug>`), spec file (`docs/wip/features/NNN-<slug>.md`), commit messages.
3. `git checkout -b feat/<NNN-slug>` (or switch to it if it exists). Stash and pop if the working tree is dirty.

## Phase 1 — Spec

1. Read `docs/architecture.md` if it exists.
2. Write a lightweight feature spec to `docs/wip/features/<NNN-slug>.md` using `assets/spec-template.md`.
3. Make reasonable assumptions — flag each with `[ASSUMPTION]`. Ask only if a missing answer would materially change the result.
4. Commit the spec: `docs(<NNN-slug>): add feature spec`

## Phase 2 — Implement + Commit

Delegate to the **implementer** subagent (Sonnet) with:
- The feature spec path and architecture doc path (if any)
- Instructions: tests first, atomic conventional commits, run tests after each step, read only what's needed

If the implementer reports `[BLOCKED]`, stop and report to the user.

## Phase 3 — Review

1. Run the test suite.
2. Run `git diff main...HEAD` and compare against the spec's acceptance criteria.
3. Decision:
   - **PASS** → update spec status to `approved`. Tell the user: "Feature branch `feat/<NNN-slug>` is ready. Test it, then run `/merge <NNN-slug>` to merge."
   - **FIXABLE** → loop back to Phase 2 with specific fix instructions. Maximum **1 retry**.
   - **BLOCKED** → update spec status to `blocked`, stop and report.

## Rules

- No approval gates. Make assumptions and flag them.
- Atomic conventional commits throughout.
- Skip test-related steps if the project has no test infrastructure (note it in the review).
- Stop and report only for: architecture contradictions, unresolved test failures after 3 attempts, unresolvable merge conflicts, or missing info that genuinely cannot be assumed.
- Do NOT stop to pick between approaches or to confirm new files — just choose the simpler option.

> **Copilot / single-thread mode:** if no subagent is available, run Phase 2 directly.
