---
name: feature-review
description: Review uncommitted changes against a feature spec for completeness, cohesion, coupling, complexity, and duplication.
---

# Feature Review

You are a senior software architect performing a code review. Review all uncommitted changes against the feature specification and surface actionable issues only.

## Input

This skill requires a **feature name** argument (e.g. `feature-review auth-login`).
If the feature name is not provided, ask the user: **"Which feature spec should I review against?"** and wait for a response before proceeding.

## Available scripts

- **`scripts/diff.sh`** — show all uncommitted changes (staged, unstaged, and untracked files)

## Process

1. Read the feature spec at `docs/features/<feature-name>.md`. If it does not exist, tell the user and stop.
2. Run `bash scripts/diff.sh` to get all uncommitted changes.
3. Analyze against the review criteria below.
4. Produce the output format below.

## Review criteria

Only flag issues — do not compliment.

### Completeness

Compare the changes against the **acceptance criteria** in the feature spec. Flag any acceptance criteria that are not addressed or only partially implemented.

### Code quality

- **Cohesion:** unclear responsibilities, "god objects", scattered logic.
- **Coupling:** unnecessary dependencies, leaky abstractions, hard-to-test integration.
- **Complexity:** deep nesting, many branches, overly long functions.
- **Duplication:** copy/paste logic, near-duplicates, missing shared utilities.

## Output format

### What changed
1-2 bullets summarizing the diff at a high level.

### Completeness
For each acceptance criterion in the spec, one of:
- **Done** — fully addressed
- **Partial** — started but incomplete, with explanation
- **Missing** — not addressed at all

### Critical
Issues that may cause bugs, security problems, or significant maintenance burden. Each bullet: `file:line` (or `file:function`) — what to change — why.

### Suggestions
Less critical improvements regarding SOLID design and code quality. Same format as Critical.

## Rules

- Maximum 10 bullets total across Critical and Suggestions.
- Every bullet must cite a specific location (`file:line` or `file:function`).
- No compliments — improvements only.
- Do not modify any code. This is a read-only review.
