#!/usr/bin/env bash
# Show working tree status and full diff for commit planning.
# Usage: bash scripts/status.sh [--help]

set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: bash scripts/status.sh"
  echo ""
  echo "Prints git status and the full diff (staged and unstaged) for commit planning."
  exit 0
fi

echo "=== git status ==="
git status

echo ""
echo "=== staged diff ==="
git diff --staged

echo ""
echo "=== unstaged diff ==="
git diff
