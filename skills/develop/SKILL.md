---
name: develop
description: "Orchestrate feature delivery: implement, commit, review, and loop until approved or blocked."
---

# Develop

You are the architect/coordinator. Your job is to deliver a feature by orchestrating four phases: implement, commit, review, and loop.

## Input

This skill requires a **feature name** argument (e.g. `develop user-auth`).
If the feature name is not provided, ask: **"Which feature should I develop?"** and wait.

## Prerequisites

Before starting, validate all of the following. Stop with `[BLOCKED: reason]` if any fail.

1. `docs/architecture.md` exists.
2. `docs/features/<name>.md` exists with `Status: draft`.
3. You are on the `feat/<name>` branch.

## Phase 1 — Implement

Read `docs/architecture.md` and `docs/features/<name>.md`. Write or update tests from the feature test plan, then implement production code until acceptance criteria are satisfied or a blocker is found.

Run tests after each logical step. If a blocker is found, stop with `[BLOCKED: reason]`.

Do NOT commit during this phase — leave changes in the working tree.

**Claude Code:** delegate to the `implementer` subagent.

## Phase 2 — Commit

Inspect the working tree diff. Group changes into atomic conventional commits and propose commit messages. Present the plan for architect approval. Create commits only after approval.

**Claude Code:** delegate to the `commit-planner` subagent.

## Phase 3 — Review

Compare the committed diff against the feature spec. Check acceptance criteria, test coverage, and code quality. Write the review report to `docs/reviews/<name>.md`. Update the feature spec status to `approved` or `changes-requested`.

**Claude Code:** delegate to the `reviewer` subagent.

## Phase 4 — Loop

- If the review returns `approved`, report success and point to `/merge <name>` as the next step.
- If the review returns `changes-requested`, loop back to Phase 1 with the review findings. Maximum **2 review rounds**. If issues persist after the second round, stop with `[BLOCKED: review issues unresolved after 2 rounds]`.

## Rules

- Do not make architectural decisions — flag ambiguity with `[BLOCKED]` or `[ARCH CHANGE NEEDED]`.
- Do not add dependencies, modules, or behavior not in the approved spec.
- Each phase must complete before the next begins.
- Report progress to the user at the start of each phase.
