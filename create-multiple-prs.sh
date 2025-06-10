#!/bin/bash

# Script to create multiple PRs for testing merge queue
# Usage: ./create-multiple-prs.sh [number_of_prs]

NUM_PRS=${1:-3}
BASE_BRANCH="main"

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

describe('Feature $i', () => {
  test('should have correct ID', () => {
    // Always fail in merge queue, pass in PR workflows
    if (isInMergeQueue) {
      throw new Error('Test failure in merge queue');
    }

    expect(feature.id).toBe($i);
  });

  test('should execute successfully', () => {
    const result = feature.execute();
    expect(result.status).toBe('success');
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
  git push origin $BRANCH_NAME

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

  gh pr create \
    --title "Feature $i: Add test feature for merge queue" \
    --body "$PR_BODY" \
    --base $BASE_BRANCH \
    --head $BRANCH_NAME

  echo "PR $i created successfully!"

  # Return to main branch for next PR
  git checkout $BASE_BRANCH

  # Small delay to avoid rate limiting
  sleep 2
done

echo ""
echo "Successfully created $NUM_PRS pull requests!"
echo ""
echo "Next steps:"
echo "1. Review the PRs in GitHub"
echo "2. Approve each PR (or use auto-approve if configured)"
echo "3. Add PRs to merge queue to test behavior"
echo ""
echo "To approve all PRs quickly (requires appropriate permissions):"
echo "gh pr list --author @me --json number --jq '.[].number' | xargs -I {} gh pr review {} --approve"
