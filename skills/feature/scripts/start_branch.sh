#!/usr/bin/env bash
# Create or switch to the local feature branch for a feature spec.
# Usage: bash scripts/start_branch.sh FEATURE_NAME [BASE_BRANCH]

set -euo pipefail

usage() {
  echo "Usage: bash scripts/start_branch.sh FEATURE_NAME [BASE_BRANCH]"
  echo ""
  echo "Creates or switches to feat/<feature-name>. New branches are created from BASE_BRANCH (default: main)."
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

FEATURE_NAME="${1:-}"
BASE_BRANCH="${2:-main}"

if [[ -z "$FEATURE_NAME" ]]; then
  echo "Error: FEATURE_NAME is required."
  echo ""
  usage
  exit 1
fi

FEATURE_SLUG="$(printf '%s' "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"

if [[ -z "$FEATURE_SLUG" ]]; then
  echo "Error: could not derive a branch name from '$FEATURE_NAME'."
  exit 1
fi

FEATURE_BRANCH="feat/$FEATURE_SLUG"
CURRENT_BRANCH="$(git branch --show-current)"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree must be clean before creating or switching feature branches."
  exit 1
fi

if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  echo "Error: base branch '$BASE_BRANCH' does not exist locally."
  exit 1
fi

if git show-ref --verify --quiet "refs/heads/$FEATURE_BRANCH"; then
  git switch "$FEATURE_BRANCH"
  echo "Switched to existing feature branch: $FEATURE_BRANCH"
  exit 0
fi

if [[ "$CURRENT_BRANCH" != "$BASE_BRANCH" ]]; then
  echo "Error: create new feature branches from '$BASE_BRANCH'. Currently on '${CURRENT_BRANCH:-detached HEAD}'."
  exit 1
fi

git switch -c "$FEATURE_BRANCH"
echo "Created and switched to feature branch: $FEATURE_BRANCH"
