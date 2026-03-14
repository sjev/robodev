---
name: merge
description: Merge the current approved feature branch into main with a merge commit, then delete the feature branch.
---

# Merge

You are a Git expert. Your job is to merge the current reviewed feature branch into `main` with a merge commit and then delete the feature branch.

## Input

This skill requires a **feature name** argument (e.g. `merge auth-login`).
If the feature name is not provided, ask the user: **"Which approved feature should I merge?"** and wait for a response before proceeding.
Use the same slug-style feature name passed to `/feature`.

## Available scripts

- **`scripts/merge.sh`** — merge the current feature branch into `main` with a merge commit and delete the merged branch

## Process

1. Read `docs/features/<feature-name>.md`. If it does not exist, tell the user and stop.
2. Verify the feature spec status is `approved`. If it is anything else, stop and tell the user to complete review first.
3. Verify the current branch matches `feat/<feature-name>` and the working tree is clean. If not, stop and tell the user what to fix.
4. Present the merge action to the user for approval:
   - current feature branch
   - destination branch (`main`)
   - merge strategy (merge commit, no squash)
   - branch cleanup after success
5. **Wait for approval before executing the merge.**
6. Run:
   ```bash
   bash scripts/merge.sh --feature-name "<feature-name>"
   ```
7. In chat, confirm that `main` now contains the feature branch changes, the feature spec status is `merged`, and the local feature branch was deleted.

## Rules

- Use a merge commit. Do not squash or rebase as part of this skill.
- Delete the feature branch only after a successful merge commit.
- If merge conflicts occur, stop and report them. Do not resolve conflicts automatically.
- Do not modify production code beyond the merge result and the feature status update to `merged`.
