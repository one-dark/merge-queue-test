// Tests for feature 1
const feature = require('./feature');

// Check if we're running in GitHub merge queue
const isInMergeQueue = process.env.GITHUB_EVENT_NAME === 'merge_group';

describe('Feature 1', () => {
  test('should have correct ID', () => {
    // Make test flaky in merge queue (25% chance of failure)
    if (isInMergeQueue && Math.random() < 0.25) {
      throw new Error('Flaky test failure in merge queue');
    }
    
    expect(feature.id).toBe(1);
  });

  test('should execute successfully', () => {
    // Make test flaky in merge queue (20% chance of failure)
    if (isInMergeQueue && Math.random() < 0.2) {
      throw new Error('Flaky test failure in merge queue');
    }
    
    const result = feature.execute();
    expect(result.status).toBe('success');
  });
});
