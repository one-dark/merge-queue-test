#!/bin/bash

# Script to close all open PRs
# Usage: ./close-all-prs.sh [--dry-run]

DRY_RUN=false

# Parse arguments
for arg in "$@"; do
  case $arg in
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  *)
    # Unknown option
    shift
    ;;
  esac
done

# Check if gh is installed
if ! command -v gh &>/dev/null; then
  echo "GitHub CLI (gh) is required. Install it from: https://cli.github.com/"
  exit 1
fi

echo "Fetching open PRs..."

# Get all open PRs
PR_NUMBERS=$(gh pr list --state open --json number --jq '.[].number')

if [ -z "$PR_NUMBERS" ]; then
  echo "No open PRs found."
  exit 0
fi

PR_COUNT=$(echo "$PR_NUMBERS" | wc -l | tr -d ' ')
echo "Found $PR_COUNT open PR(s)"

if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "DRY RUN - Would close the following PRs:"
  for pr_num in $PR_NUMBERS; do
    PR_TITLE=$(gh pr view $pr_num --json title --jq '.title')
    echo "  #$pr_num: $PR_TITLE"
  done
  echo ""
  echo "Run without --dry-run to actually close PRs"
  exit 0
fi

echo ""
echo "Closing all open PRs..."

SUCCESS_COUNT=0
FAIL_COUNT=0

for pr_num in $PR_NUMBERS; do
  echo ""
  echo "Closing PR #$pr_num..."
  
  if gh pr close $pr_num; then
    echo "✓ PR #$pr_num closed"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    echo "✗ Failed to close PR #$pr_num"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done

echo ""
echo "Summary:"
echo "  Successfully closed: $SUCCESS_COUNT"
echo "  Failed: $FAIL_COUNT"
echo "  Total: $PR_COUNT"