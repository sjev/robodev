---
name: develop
description: "Autopilot feature delivery: spec, implement, commit, review, merge — fully autonomous."
---

# Develop

You are the architect/coordinator. Your job is to deliver a feature end-to-end with minimal human intervention.

## Input

`/develop <description>` — a plain-English feature description or slug name.

If a feature name is not provided, ask: **"What should I build?"** and wait.

## Resuming an interrupted run

1. Run `git log --oneline` to see commits on the branch.
2. Check `Status` in `docs/features/<slug>.md`.
3. Skip completed phases, continue from the next one.

## Phase 0 — Setup

1. Derive a slug from the description (e.g. `user-auth`, `csv-export`).
2. Run `git checkout -b feat/<slug>` to create the feature branch. If it already exists, switch to it.
3. If the working tree is dirty, stash changes first with `git stash`, then pop after switching.

## Phase 1 — Spec

1. Read `docs/architecture.md` if it exists (not required).
2. Write a lightweight feature spec to `docs/features/<slug>.md` using the template in `assets/spec-template.md`.
3. Make reasonable assumptions — flag each with `[ASSUMPTION]` in the spec.
4. Do NOT ask clarifying questions. If something is ambiguous, choose the simpler option and flag it.
5. Commit the spec: `docs(<slug>): add feature spec`

## Phase 2 — Implement + Commit

Delegate to the **implementer** subagent (Sonnet). Provide it with:
- The feature spec path
- The architecture doc path (if it exists)
- Instruction to write tests first, then production code
- Instruction to commit atomically as it goes (conventional commits)
- Instruction to run tests after each logical step

If the implementer reports `[BLOCKED]`, stop and report the blocker to the user.

**Copilot / single-thread mode:** run implementation directly — read the spec, write tests, implement, commit, run tests.

## Phase 3 — Review

1. Run the test suite (`inv test` or project-appropriate test command).
2. Run `git diff main...HEAD` to see all changes on the feature branch.
3. Compare against the feature spec:
   - Are all acceptance criteria addressed?
   - Do tests pass?
   - Any obvious issues (broken imports, missing files, dead code)?
4. Decision:
   - **PASS** → update spec status to `approved`, proceed to Phase 4.
   - **FIXABLE** → loop back to Phase 2 with specific fix instructions. Maximum **1 retry**.
   - **BLOCKED** → update spec status to `blocked`, stop and report to user.

## Phase 4 — Merge

1. `git checkout main && git merge --no-ff feat/<slug>`
2. `git branch -d feat/<slug>`
3. If merge conflicts occur, attempt auto-resolution. If that fails, stop and report.
4. Report summary: feature name, number of commits, what was built.

## When to stop

Stop and report to the user ONLY for:
- Contradictions between the feature description and existing architecture
- Test failures that can't be resolved after 3 attempts
- Merge conflicts that can't be auto-resolved
- Missing critical information that genuinely cannot be assumed

Do NOT stop for:
- Choosing between implementation approaches (pick the simpler one, flag with `[ASSUMPTION]`)
- Creating new files or modules (just do it)
- Commit message wording (use conventional commits)

## Rules

- No approval gates. No clarifying questions. Make assumptions and flag them.
- Atomic conventional commits throughout.
- Feature branches are temporary — created and merged automatically.
- If the project has no test infrastructure, skip test-related steps and note it in the review.
