#!/usr/bin/env bash
# Show all uncommitted changes (staged, unstaged, and untracked files).
# Usage: bash scripts/diff.sh

set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: bash scripts/diff.sh"
  echo ""
  echo "Shows all uncommitted changes: staged, unstaged, and untracked files."
  exit 0
fi

echo "=== Staged changes ==="
git diff --cached

echo ""
echo "=== Unstaged changes ==="
git diff

echo ""
echo "=== Untracked files ==="
git ls-files --others --exclude-standard | while read -r f; do
  echo "--- /dev/null"
  echo "+++ b/$f"
  cat "$f"
  echo ""
done
