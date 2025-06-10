#!/bin/bash

# Script to create multiple PRs for testing merge queue
# Usage: ./create-multiple-prs.sh [number_of_prs] [--merge]

# Parse arguments
BASE_BRANCH="main"
MERGE_FLAG=false
NUM_PRS=3

for arg in "$@"; do
  case $arg in
  --merge)
    MERGE_FLAG=true
    shift
    ;;
  [0-9]*)
    NUM_PRS=$arg
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

echo "Creating $NUM_PRS pull requests..."

# Make sure we're on main and up to date
git checkout $BASE_BRANCH
git pull origin $BASE_BRANCH

for i in $(seq 1 $NUM_PRS); do
  BRANCH_NAME="feature/test-$i-$(date +%s)"

  echo ""
  echo "Creating PR $i/$NUM_PRS..."

  # Create and checkout new branch
  git checkout -b $BRANCH_NAME

  # Create unique changes
  mkdir -p "feature-$i"

  # Add main feature file
  cat >"feature-$i/feature.js" <<EOF
// Feature $i implementation
const feature$i = {
  id: $i,
  name: 'Feature $i',
  timestamp: '$(date -u +"%Y-%m-%dT%H:%M:%SZ")',

  execute() {
    console.log('Executing feature $i');
    return {
      status: 'success',
      data: 'Feature $i completed'
    };
  }
};

module.exports = feature$i;
EOF

  # Add test file
  cat >"feature-$i/feature.test.js" <<EOF
// Tests for feature $i
const feature = require('./feature');
const { test, describe } = require('node:test');
const assert = require('node:assert');

// Check if we're running in GitHub merge queue
const isInMergeQueue = process.env.GITHUB_EVENT_NAME === 'merge_group';
console.log('isInMergeQueue', isInMergeQueue);

describe('Feature $i', () => {
  test('should have correct ID', () => {
    // Always fail in merge queue, pass in PR workflows
    if (isInMergeQueue) {
      throw new Error('Test failure in merge queue');
    }

    assert.strictEqual(feature.id, $i);
  });

  test('should execute successfully', () => {
    const result = feature.execute();
    assert.strictEqual(result.status, 'success');
  });
});
EOF

  # Add README for the feature
  cat >"feature-$i/README.md" <<EOF
# Feature $i

This is test feature $i for merge queue testing.

## Changes
- Added feature implementation
- Added corresponding tests
- Created at: $(date)

## Purpose
Testing merge queue behavior with multiple PRs.
EOF

  # Add random additional file to create more changes
  if [ $((i % 2)) -eq 0 ]; then
    cat >"feature-$i/config.json" <<EOF
{
  "feature": $i,
  "enabled": true,
  "settings": {
    "timeout": $((i * 1000)),
    "retries": $((i + 2))
  }
}
EOF
  fi

  # Stage and commit changes
  git add "feature-$i/"
  git commit -m "Add feature $i

- Implement feature $i functionality
- Add comprehensive tests
- Include documentation
- Part of merge queue testing"

  # Push branch
  git push -q origin $BRANCH_NAME

  # Create PR using gh
  PR_BODY="## Description
This PR adds feature $i as part of merge queue testing.

## Changes
- New feature implementation in \`feature-$i/\`
- Test coverage included
- Documentation added

## Testing
- All checks should pass (with possible random failures)
- Ready for merge queue testing

## Context
PR $i of $NUM_PRS in this test batch."

  PR_URL=$(gh pr create \
    --title "Feature $i: Add test feature for merge queue" \
    --body "$PR_BODY" \
    --base $BASE_BRANCH \
    --head $BRANCH_NAME)

  echo "PR $i created successfully!"

  # Auto-merge the PR if --merge flag is set
  if [ "$MERGE_FLAG" = true ]; then
    PR_NUMBER=$(echo "$PR_URL" | grep -o '[0-9]*$')
    echo "Auto-merging PR #$PR_NUMBER..."
    gh pr merge $PR_NUMBER --auto
    echo "PR #$PR_NUMBER merged!"
  fi

  # Return to main branch for next PR
  git checkout $BASE_BRANCH
done

echo ""
echo "Successfully created $NUM_PRS pull requests!"

if [ "$MERGE_FLAG" = true ]; then
  echo "All PRs have been automatically merged!"
fi

echo ""
echo "Next steps:"
if [ "$MERGE_FLAG" = true ]; then
  echo "1. PRs have been automatically merged"
  echo "2. Check the merge queue behavior and results"
else
  echo "1. Review the PRs in GitHub"
  echo "2. Approve and merge each PR (or use --merge flag next time)"
  echo "3. Add PRs to merge queue to test behavior"
  echo ""
  echo "To merge all PRs quickly (requires appropriate permissions):"
  echo "gh pr list --author @me --json number --jq '.[].number' | xargs -I {} gh pr merge {} --merge"
fi
