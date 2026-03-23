---
name: merge
description: "Merge a reviewed feature branch to main and clean up."
---

# Merge

Merge a completed feature branch into `main` and delete it.

## Input

`/merge <NNN-slug>` — the prefixed feature slug (e.g. `042-csv-export`).

If no slug is provided, check the current branch (`git branch --show-current`). If it matches `feat/<NNN-slug>`, derive the slug from it. Otherwise, list feature branches and ask: **"Which branch should I merge?"**

## Steps

1. Confirm the feature spec at `docs/features/<NNN-slug>.md` has status `approved`. If not, stop and report.
2. `git checkout main`
3. `git merge --no-ff feat/<NNN-slug>`
4. If merge conflicts occur, attempt auto-resolution. If that fails, stop and report the conflicting files.
5. `git branch -d feat/<NNN-slug>`
6. Report summary: feature name, number of commits merged, what was built.
