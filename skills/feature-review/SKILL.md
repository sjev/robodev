---
name: feature-review
description: Review uncommitted changes against a feature spec and produce a written review report with actionable issues, then mark the feature spec status as reviewed.
---

# Feature Review

You are a senior software architect performing a code review. Review all uncommitted changes against the feature specification and surface actionable issues only.

## Input

This skill requires a **feature name** argument (e.g. `feature-review auth-login`).
If the feature name is not provided, ask the user: **"Which feature spec should I review against?"** and wait for a response before proceeding.

## Available scripts

- **`scripts/diff.sh`** — show all uncommitted changes (staged, unstaged, and untracked files)

## Deliverables

- A review report at `docs/reviews/<feature-name>.md`
- The feature spec status updated to `Status: reviewed` in `docs/features/<feature-name>.md`

## Process

1. Read the feature spec at `docs/features/<feature-name>.md`. If it does not exist, tell the user and stop.
2. Ensure `docs/reviews/` exists (create it if missing).
3. Run `bash scripts/diff.sh` to capture all uncommitted changes.
4. Run tests (`invoke test` by default) and capture pass/fail output. If you cannot run tests, explicitly say so in the report and set Outcome to `needs-changes`.
5. Analyze against the review criteria below.
6. Write/update the review report at `docs/reviews/<feature-name>.md` using the report format below.
7. Update the feature spec status to `Status: reviewed` in `docs/features/<feature-name>.md` (add the Status line near the top if missing). Do this even if the Outcome is `needs-changes`.
8. In chat, paste the short “Chat output” section below and point to the report file path.

## Review criteria

Only flag issues — do not compliment.

### Completeness

Compare the changes against the **acceptance criteria** in the feature spec. Flag any acceptance criteria that are not addressed or only partially implemented.

### Test coverage

If the feature spec has a **test plan**, verify:
- Every test plan item (T-01, T-02, …) has a corresponding test function.
- All tests pass.
- Flag any AC without test coverage.

### Code quality

- **Cohesion:** unclear responsibilities, "god objects", scattered logic.
- **Coupling:** unnecessary dependencies, leaky abstractions, hard-to-test integration.
- **Complexity:** deep nesting, many branches, overly long functions.
- **Duplication:** copy/paste logic, near-duplicates, missing shared utilities.

## Output format

### Report format (`docs/reviews/<feature-name>.md`)

Use this structure:

#### Header
- Feature: `<feature-name>`
- Spec: `docs/features/<feature-name>.md`
- Reviewed by: `LLM model name and version`
- Reviewed at: ISO-8601 timestamp
- Review scope: uncommitted changes (staged/unstaged/untracked)
- Outcome: `needs-changes` or `ok-to-merge`

Outcome rubric:
- `ok-to-merge` only if: all acceptance criteria are **Done**, all Test Plan items are **Covered** and tests pass, and there are **no Critical** issues.
- Otherwise: `needs-changes`.

#### What changed
1-2 bullets summarizing the diff at a high level.

#### Completeness
For each acceptance criterion in the spec, one of:
- **Done** — fully addressed
- **Partial** — started but incomplete, with explanation
- **Missing** — not addressed at all

#### Test coverage
For each test plan item:
- **Covered** — test exists and passes
- **Failing** — test exists but fails
- **Missing** — no corresponding test

#### Critical
Issues that may cause bugs, security problems, or significant maintenance burden. Each bullet: `file:line` (or `file:function`) — what to change — why.

#### Suggestions
Less critical improvements regarding SOLID design and code quality. Same format as Critical.

#### Next actions
3-5 bullets that turn the review into an executable follow-up plan (e.g., “Fix C-01, add tests for T-02, refactor X to reduce coupling”). If there are Critical items, the first Next action must address them.

### Chat output

In chat, output:

- `docs/reviews/<feature-name>.md` — written review report
- `docs/features/<feature-name>.md` — status set to `reviewed`
- 1 sentence stating the Outcome and the top 1-2 blocking issues (if any)

## Rules

- Maximum 10 bullets total across Critical and Suggestions.
- Every bullet must cite a specific location (`file:line` or `file:function`).
- No compliments — improvements only.
- Do not modify production code. Updating `docs/features/<feature-name>.md` and writing `docs/reviews/<feature-name>.md` are allowed.
