# Merge Queue Test Repository

This repository is set up to test GitHub's merge queue functionality, including SHA behavior, queue ordering, and handling of failed checks.

## Setup

1. **Enable GitHub Actions** in your repository settings if not already enabled.

2. **Set up branch protection and merge queue**:
   ```bash
   # Make sure you have GitHub CLI installed and authenticated
   ./setup-branch-protection.sh
   ```

3. **Create sample files** for testing:
   ```bash
   ./create-sample-files.sh
   ```

## Testing Scenarios

### Understanding SHA Behavior

The workflows include detailed SHA logging to help understand:
- How SHAs change when PRs enter the merge queue
- The difference between PR head SHA and merge queue SHA
- How merge commits are created in the queue

### Test Case 1: Single PR in Queue

1. Create a new branch and make changes:
   ```bash
   git checkout -b feature/test-1
   echo "Test 1" > test1.txt
   git add test1.txt
   git commit -m "Add test1.txt"
   git push origin feature/test-1
   ```

2. Create a PR and observe:
   - Initial PR SHA in the checks
   - After approval, add to merge queue
   - New merge queue SHA (different from PR SHA)
   - Check results with the new SHA

### Test Case 2: Multiple PRs in Queue

1. Create multiple PRs quickly:
   ```bash
   ./create-multiple-prs.sh 3
   ```

2. Approve all PRs and add them to the merge queue simultaneously

3. Observe:
   - How PRs are grouped in the queue
   - SHA changes for each PR when entering the queue
   - Order of processing
   - How failure of one PR affects others

### Test Case 3: Handling Failed Checks

The repository includes intentionally flaky tests:

- **flaky-test**: 30% failure rate
- **unstable-integration**: 50% failure rate  
- **timing-sensitive**: Fails during minutes ending in 3, 6, or 9

To test failure scenarios:

1. Create a PR and add to merge queue
2. If all checks pass, close and retry (statistically, you'll hit failures)
3. Observe:
   - How the merge queue handles failures
   - Whether the PR is removed from queue
   - If other PRs in queue are affected

### Test Case 4: Queue Ordering and Dependencies

1. Create PRs with different priorities:
   ```bash
   # Create a large PR
   git checkout -b feature/large-change
   for i in {1..10}; do echo "Line $i" >> large-file.txt; done
   git add large-file.txt
   git commit -m "Large change"
   git push origin feature/large-change

   # Create a small urgent fix
   git checkout main
   git pull
   git checkout -b fix/urgent
   echo "urgent fix" > urgent.txt
   git add urgent.txt
   git commit -m "Urgent fix"
   git push origin fix/urgent
   ```

2. Add both to merge queue and observe processing order

## Debugging Tips

### Viewing SHA Information

Each workflow run logs detailed SHA information:
- Check the "Show SHA information" step in any workflow run
- Compare PR SHA vs merge queue SHA
- Track how SHAs change through the process

### Understanding Merge Queue Events

The workflows differentiate between:
- `pull_request` events (normal PR checks)
- `merge_group` events (merge queue checks)

Look for "Event Name" in the logs to understand the context.

### Monitoring Queue Status

Use GitHub's merge queue UI:
1. Go to the Pull Requests tab
2. Click on "Merge Queue" to see current queue status
3. Observe position, estimated time, and check status

## Common Issues and Solutions

### Issue: Checks failing in merge queue but passing in PR
- **Cause**: Different SHA or merge conflicts
- **Solution**: Check SHA differences in logs, ensure base branch is up-to-date

### Issue: PRs stuck in queue
- **Cause**: Consistently failing flaky tests
- **Solution**: Re-run failed checks or temporarily disable flaky tests

### Issue: Queue processing seems slow
- **Cause**: Conservative queue settings or many failing checks
- **Solution**: Adjust `max_entries_to_merge` and `min_entries_to_merge` in setup script

## Advanced Testing

### Simulating Production Conditions

1. **High traffic**: Use `create-multiple-prs.sh` with higher numbers
2. **Complex conflicts**: Create PRs that modify same files
3. **Long-running tests**: Modify workflows to add delays

### Analyzing Queue Performance

Track metrics:
- Time from PR approval to merge
- Queue failure rate
- Impact of grouping strategies

## Cleanup

To remove test branches after testing:
```bash
# List all test branches
git branch -r | grep 'origin/feature/test-\|origin/fix/' 

# Delete remote branches
git push origin --delete feature/test-1 feature/test-2 # etc
```