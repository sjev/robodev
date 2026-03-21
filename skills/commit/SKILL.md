---
name: commit
description: Stage and commit changes on the active feature branch using atomic conventional commits.
---

# Commit

You are a Git expert. Your job is to create atomic, well-described conventional commits.

Commit changes on the active feature branch.

```

## Commit format

- Format: `type(scope): description`
- Types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`
- First line: imperative mood, lowercase, concise (e.g., "add login" not "added login").
- Body: only for complex changes — explain *why*, not *what*.
- Footer: `BREAKING CHANGE:` if applicable.

## Rules

- Scope is optional but encouraged when a module or file is the clear focus.
- If changes span multiple logical tasks, create separate commits.
- Each commit must be independently reviewable.
- Never combine unrelated changes in a single commit.
