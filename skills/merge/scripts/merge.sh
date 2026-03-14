#!/usr/bin/env bash
# Merge the current feature branch into the base branch with a merge commit and delete it on success.
# Usage: bash scripts/merge.sh --feature-name FEATURE_NAME [--base-branch BASE_BRANCH]

set -euo pipefail

usage() {
  echo "Usage: bash scripts/merge.sh --feature-name FEATURE_NAME [--base-branch BASE_BRANCH]"
  echo ""
  echo "Merges the current feature branch into BASE_BRANCH (default: main) with a merge commit,"
  echo "updates docs/features/<feature-name>.md to Status: merged, and deletes the merged feature branch."
}

FEATURE_NAME=""
BASE_BRANCH="main"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    --feature-name)
      [[ -z "${2:-}" ]] && { echo "Error: --feature-name requires a value."; exit 1; }
      FEATURE_NAME="$2"
      shift 2
      ;;
    --base-branch)
      [[ -z "${2:-}" ]] && { echo "Error: --base-branch requires a value."; exit 1; }
      BASE_BRANCH="$2"
      shift 2
      ;;
    *)
      echo "Error: unknown option '$1'."
      echo ""
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$FEATURE_NAME" ]]; then
  echo "Error: --feature-name is required."
  echo ""
  usage
  exit 1
fi

CURRENT_BRANCH="$(git branch --show-current)"
FEATURE_BRANCH="feat/$FEATURE_NAME"
FEATURE_DOC="docs/features/$FEATURE_NAME.md"

if [[ -z "$CURRENT_BRANCH" ]]; then
  echo "Error: not on a branch."
  exit 1
fi

if [[ "$CURRENT_BRANCH" != "$FEATURE_BRANCH" ]]; then
  echo "Error: current branch '$CURRENT_BRANCH' does not match expected feature branch '$FEATURE_BRANCH'."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree must be clean before merging."
  exit 1
fi

if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  echo "Error: base branch '$BASE_BRANCH' does not exist locally."
  exit 1
fi

if [[ ! -f "$FEATURE_DOC" ]]; then
  echo "Error: feature doc '$FEATURE_DOC' does not exist."
  exit 1
fi

if [[ "$(git rev-list --count "$BASE_BRANCH..$FEATURE_BRANCH")" -eq 0 ]]; then
  echo "Error: branch '$FEATURE_BRANCH' has no commits ahead of '$BASE_BRANCH'."
  exit 1
fi

git switch "$BASE_BRANCH"

if ! git merge --no-ff --no-commit "$FEATURE_BRANCH"; then
  git merge --abort >/dev/null 2>&1 || true
  git switch "$FEATURE_BRANCH" >/dev/null 2>&1 || true
  echo "Error: merge conflicts detected while merging '$FEATURE_BRANCH' into '$BASE_BRANCH'. Resolve them manually."
  exit 1
fi

python - "$FEATURE_DOC" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
lines = path.read_text().splitlines()

for idx, line in enumerate(lines):
    if line.startswith("Status: "):
        lines[idx] = "Status: merged"
        break
else:
    if lines and lines[0].startswith("# "):
        lines.insert(1, "")
        lines.insert(2, "Status: merged")
    else:
        lines.insert(0, "Status: merged")

path.write_text("\n".join(lines) + "\n")
PY

git add "$FEATURE_DOC"
git commit --message "Merge branch '$FEATURE_BRANCH'"
git branch -d "$FEATURE_BRANCH"

echo "Merged '$FEATURE_BRANCH' into '$BASE_BRANCH' and deleted the local feature branch."
