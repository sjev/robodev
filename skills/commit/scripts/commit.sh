#!/usr/bin/env bash
# Stage specified files and create a commit.
# Usage: bash scripts/commit.sh --message "type(scope): description" [--] file1 file2 ...

set -euo pipefail

usage() {
  echo "Usage: bash scripts/commit.sh --message MESSAGE [--] FILE [FILE...]"
  echo ""
  echo "Options:"
  echo "  --message MESSAGE   Commit message (required)"
  echo "  --help              Show this help"
  echo ""
  echo "Examples:"
  echo "  bash scripts/commit.sh --message \"feat(auth): add login endpoint\" src/auth.py tests/test_auth.py"
  echo "  bash scripts/commit.sh --message \"chore: update deps\" -- requirements.txt"
}

MESSAGE=""
FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help) usage; exit 0 ;;
    --message)
      [[ -z "${2:-}" ]] && { echo "Error: --message requires a value."; exit 1; }
      MESSAGE="$2"; shift 2 ;;
    --) shift; FILES+=("$@"); break ;;
    -*) echo "Error: unknown option '$1'. Run with --help for usage."; exit 1 ;;
    *) FILES+=("$1"); shift ;;
  esac
done

if [[ -z "$MESSAGE" ]]; then
  echo "Error: --message is required."
  echo ""
  usage
  exit 1
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Error: at least one file must be specified."
  echo ""
  usage
  exit 1
fi

git add -- "${FILES[@]}"
git commit --message "$MESSAGE"
