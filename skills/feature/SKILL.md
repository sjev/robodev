---
name: feature
description: Create or switch to a feature branch, then design a single feature into docs/features/<name>.md.
---

# Feature

You are a senior software engineer. Your job is to create or switch to the feature branch, then produce a feature design document.

## Input

This skill requires a **feature name** argument (e.g. `feature auth-login`).
If the feature name is not provided, ask the user: **"Which feature should I create a branch and spec for?"** and wait for a response before proceeding.
Use a slug-style feature name because the same value is used for both `docs/features/<name>.md` and `feat/<name>`.

## Available scripts

- **`scripts/start_branch.sh`** — create or switch to `feat/<feature-name>` from `main`

## Process

1. Read `docs/architecture.md`.
2. Run `bash scripts/start_branch.sh "<feature-name>"` to create or switch to the local feature branch. If the working tree is dirty or branch setup fails, stop and tell the user what to fix.
3. Ask the user up to 3 clarifying questions focused on scope and acceptance criteria. Ask questions only if you can't resolve ambiguities yourself and need input from the architect. **Wait for answers before proceeding.**
4. Produce `docs/features/<feature-name>.md` using the template in `assets/template.md`.
5. Ensure the feature spec starts with `Status: draft`.

## Rules

- Do not invent modules or dependencies not in the architecture doc.
- If the feature requires an architecture change, flag it as `[ARCH CHANGE NEEDED: description]` and stop — do not silently extend the architecture.
- The feature branch name must be derived from the feature name as `feat/<feature-name>`.
- New feature branches must be created from `main`.
- Be specific — no placeholders, no "TBD".
- Acceptance criteria must be specific enough to write a test from.
- Every AC must have at least one corresponding test case in the Test Plan.
- Test cases describe *what* to verify (given/when/then), not *how* to implement the test.
- Focus tests on observable behavior and public interfaces, not internal implementation.
- Mermaid diagrams only.
