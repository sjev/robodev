#!/usr/bin/env bash
# Show committed changes for the current feature branch against a base branch.
# Usage: bash scripts/diff.sh [BASE_BRANCH]

set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: bash scripts/diff.sh [BASE_BRANCH]"
  echo ""
  echo "Shows the committed diff for the current feature branch against BASE_BRANCH (default: main)."
  exit 0
fi

BASE_BRANCH="${1:-main}"
CURRENT_BRANCH="$(git branch --show-current)"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree must be clean before reviewing a branch diff."
  exit 1
fi

if [[ -z "$CURRENT_BRANCH" ]]; then
  echo "Error: not on a branch."
  exit 1
fi

if [[ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]]; then
  echo "Error: review must run from a feature branch, not '$BASE_BRANCH'."
  exit 1
fi

if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  echo "Error: base branch '$BASE_BRANCH' does not exist locally."
  exit 1
fi

if [[ "$(git rev-list --count "$BASE_BRANCH..$CURRENT_BRANCH")" -eq 0 ]]; then
  echo "Error: branch '$CURRENT_BRANCH' has no committed changes ahead of '$BASE_BRANCH'."
  exit 1
fi

echo "=== Review scope ==="
echo "Base branch: $BASE_BRANCH"
echo "Feature branch: $CURRENT_BRANCH"

echo ""
echo "=== Commits ahead of $BASE_BRANCH ==="
git --no-pager log --oneline "$BASE_BRANCH..$CURRENT_BRANCH"

echo ""
echo "=== Changed files ==="
git --no-pager diff --name-status "$BASE_BRANCH...$CURRENT_BRANCH"

echo ""
echo "=== Full diff ($BASE_BRANCH...$CURRENT_BRANCH) ==="
git --no-pager diff "$BASE_BRANCH...$CURRENT_BRANCH"
