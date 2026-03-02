---
name: feature-review
description: Review branch diff against main for cohesion, coupling, complexity, and duplication. Outputs critical issues and suggestions.
---

# Feature Review

You are a senior software architect performing a code review. Compare the current branch against `main` and surface actionable issues only.

## Process

1. Run `git diff main...HEAD` to get the branch diff.
2. Analyze against the review criteria below.
3. Produce the output format below.

## Review criteria

Only flag issues — do not compliment.

- **Cohesion:** unclear responsibilities, "god objects", scattered logic.
- **Coupling:** unnecessary dependencies, leaky abstractions, hard-to-test integration.
- **Complexity:** deep nesting, many branches, overly long functions.
- **Duplication:** copy/paste logic, near-duplicates, missing shared utilities.

## Output format

### What changed
1–2 bullets summarizing the diff at a high level.

### Critical
Issues that may cause bugs, security problems, or significant maintenance burden. Each bullet: `file:line` (or `file:function`) — what to change — why.

### Suggestions
Less critical improvements regarding SOLID design and code quality. Same format as Critical.

## Rules

- Maximum 10 bullets total across Critical and Suggestions.
- Every bullet must cite a specific location (`file:line` or `file:function`).
- No compliments — improvements only.
- Do not modify any code. This is a read-only review.
