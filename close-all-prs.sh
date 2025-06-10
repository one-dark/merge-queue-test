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

# Function to close a single PR
close_pr() {
  local pr_num=$1
  echo "Closing PR #$pr_num..."
  
  if gh pr close $pr_num 2>&1; then
    echo "✓ PR #$pr_num closed"
    return 0
  else
    echo "✗ Failed to close PR #$pr_num"
    return 1
  fi
}

# Export function so it's available to subshells
export -f close_pr

# Close PRs in parallel using xargs
echo "$PR_NUMBERS" | xargs -I {} -P 10 bash -c 'close_pr "$@"' _ {}

# Wait for all background processes to complete
wait

echo ""
echo "All PR closure operations completed."
echo "Total PRs processed: $PR_COUNT"