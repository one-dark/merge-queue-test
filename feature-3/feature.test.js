// Tests for feature 3
const feature = require('./feature');

// Check if we're running in GitHub merge queue
const isInMergeQueue = process.env.GITHUB_EVENT_NAME === 'merge_group';

describe('Feature 3', () => {
  test('should have correct ID', () => {
    // Make test flaky in merge queue (40% chance of failure)
    if (isInMergeQueue && Math.random() < 0.4) {
      throw new Error('Flaky test failure in merge queue');
    }
    
    expect(feature.id).toBe(3);
  });

  test('should execute successfully', () => {
    // Make test flaky in merge queue (30% chance of failure)
    if (isInMergeQueue && Math.random() < 0.3) {
      throw new Error('Flaky test failure in merge queue');
    }
    
    const result = feature.execute();
    expect(result.status).toBe('success');
  });
});
