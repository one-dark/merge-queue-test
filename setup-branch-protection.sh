#!/bin/bash

# Script to set up branch protection rules with merge queue enabled
# Usage: ./setup-branch-protection.sh <owner> <repo>

OWNER=${1:-$(git config --get remote.origin.url | sed -n 's/.*github.com[:/]\([^/]*\).*/\1/p')}
REPO=${2:-$(basename -s .git $(git config --get remote.origin.url))}

if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
    echo "Usage: $0 <owner> <repo>"
    echo "Or run from within a git repository with GitHub remote"
    exit 1
fi

echo "Setting up branch protection for $OWNER/$REPO..."

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is required. Install it from: https://cli.github.com/"
    exit 1
fi

# Create branch protection rule with merge queue
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$OWNER/$REPO/branches/main/protection \
  -f "required_status_checks[strict]=true" \
  -f "required_status_checks[contexts][]=test" \
  -f "required_status_checks[contexts][]=lint" \
  -f "required_status_checks[contexts][]=build" \
  -f "required_status_checks[contexts][]=flaky-test" \
  -f "required_status_checks[contexts][]=unstable-integration" \
  -f "required_status_checks[contexts][]=timing-sensitive" \
  -f "enforce_admins=false" \
  -f "required_pull_request_reviews[dismiss_stale_reviews]=true" \
  -f "required_pull_request_reviews[require_code_owner_reviews]=false" \
  -f "required_pull_request_reviews[required_approving_review_count]=1" \
  -f "restrictions=null" \
  -f "allow_force_pushes=false" \
  -f "allow_deletions=false" \
  -f "block_creations=false" \
  -f "required_conversation_resolution=true" \
  -f "required_linear_history=false" \
  -f "allow_squash_merge=true" \
  -f "allow_merge_commit=true" \
  -f "allow_rebase_merge=true" \
  -f "use_squash_pr_title_as_default=true" \
  -f "squash_merge_commit_title=PR_TITLE" \
  -f "squash_merge_commit_message=PR_BODY"

# Enable merge queue
echo "Enabling merge queue..."
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$OWNER/$REPO/rulesets \
  -f "name=Merge Queue Rules" \
  -f "target=branch" \
  -f "enforcement=active" \
  -f "conditions[ref_name][include][]=refs/heads/main" \
  -f "conditions[ref_name][exclude]=[]" \
  -f "rules[0][type]=merge_queue" \
  -f "rules[0][parameters][check_response_timeout_minutes]=60" \
  -f "rules[0][parameters][grouping_strategy]=ALLGREEN" \
  -f "rules[0][parameters][max_entries_to_build]=5" \
  -f "rules[0][parameters][max_entries_to_merge]=5" \
  -f "rules[0][parameters][merge_method]=squash" \
  -f "rules[0][parameters][min_entries_to_merge]=1" \
  -f "rules[0][parameters][min_entries_to_merge_wait_minutes]=0"

echo "Branch protection and merge queue setup complete!"
echo ""
echo "Settings applied:"
echo "- Required status checks: test, lint, build, flaky-test, unstable-integration, timing-sensitive"
echo "- Require PR approval: 1 review"
echo "- Dismiss stale reviews: Yes"
echo "- Require conversation resolution: Yes"
echo "- Merge queue enabled with:"
echo "  - Grouping strategy: ALLGREEN"
echo "  - Max entries: 5"
echo "  - Min entries to merge: 1"
echo "  - Merge method: squash"