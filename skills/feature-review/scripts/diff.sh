#!/usr/bin/env bash
# Show the diff between the current branch and a base branch.
# Usage: bash scripts/diff.sh [BASE_BRANCH]

set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: bash scripts/diff.sh [BASE_BRANCH]"
  echo ""
  echo "Arguments:"
  echo "  BASE_BRANCH   Branch to diff against (default: main)"
  echo ""
  echo "Examples:"
  echo "  bash scripts/diff.sh"
  echo "  bash scripts/diff.sh develop"
  exit 0
fi

BASE="${1:-main}"

if ! git rev-parse --verify "$BASE" &>/dev/null; then
  echo "Error: branch '$BASE' not found."
  exit 1
fi

git diff "${BASE}...HEAD"
