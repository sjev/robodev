#!/usr/bin/env bash
# Show branch status and full diff for commit planning.
# Usage: bash scripts/status.sh [BASE_BRANCH]

set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: bash scripts/status.sh [BASE_BRANCH]"
  echo ""
  echo "Prints the current branch, git status, and the full diff (staged and unstaged) for commit planning."
  exit 0
fi

BASE_BRANCH="${1:-main}"
CURRENT_BRANCH="$(git branch --show-current)"

echo "=== current branch ==="
echo "${CURRENT_BRANCH:-detached HEAD}"

if git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1 && [[ -n "$CURRENT_BRANCH" && "$CURRENT_BRANCH" != "$BASE_BRANCH" ]]; then
  echo ""
  echo "=== commits ahead of $BASE_BRANCH ==="
  git --no-pager log --oneline "$BASE_BRANCH..$CURRENT_BRANCH"
fi

echo ""
echo "=== git status ==="
git status --short --branch

echo ""
echo "=== staged diff ==="
git diff --staged

echo ""
echo "=== unstaged diff ==="
git diff
