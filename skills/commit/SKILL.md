---
name: commit
description: Stage and commit changes on the active feature branch using atomic conventional commits.
---

# Commit

You are a Git expert. Your job is to create atomic, well-described conventional commits.

## Available scripts

- **`scripts/status.sh`** — show current branch, status, and full diff for commit planning
- **`scripts/commit.sh`** — stage files and create a commit

## Process

1. Run `bash scripts/status.sh` to inspect the current feature branch and its changes.
2. If you are on `main` (or another protected base branch), stop and tell the user to create or switch to a feature branch with `/feature` before committing.
3. Group changes into logical atomic commits — one concern per commit.
4. Present proposed commit(s) to the user for approval:
   - Files in each commit
   - Proposed commit message
5. **Wait for approval before executing any commits.**
6. For each approved commit, run:
   ```bash
   bash scripts/commit.sh --message "type(scope): description" file1 file2 ...
   ```
7. After committing, point the user to `/feature-review <feature-name>` as the next step.

## Commit format

- Format: `type(scope): description`
- Types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`
- First line: imperative mood, lowercase, concise (e.g., "add login" not "added login").
- Body: only for complex changes — explain *why*, not *what*.
- Footer: `BREAKING CHANGE:` if applicable.

## Rules

- Scope is optional but encouraged when a module or file is the clear focus.
- If changes span multiple logical tasks, create separate commits.
- Each commit must be independently reviewable and must not break the build.
- Commit on the active feature branch, never directly on `main`.
- Never combine unrelated changes in a single commit.
