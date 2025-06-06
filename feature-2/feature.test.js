// Tests for feature 2
const feature = require('./feature');

// Check if we're running in GitHub merge queue
const isInMergeQueue = process.env.GITHUB_EVENT_NAME === 'merge_group';

describe('Feature 2', () => {
  test('should have correct ID', () => {
    // Make test flaky in merge queue (35% chance of failure)
    if (isInMergeQueue && Math.random() < 0.35) {
      throw new Error('Flaky test failure in merge queue');
    }
    
    expect(feature.id).toBe(2);
  });

  test('should execute successfully', () => {
    // Make test flaky in merge queue (15% chance of failure)
    if (isInMergeQueue && Math.random() < 0.15) {
      throw new Error('Flaky test failure in merge queue');
    }
    
    const result = feature.execute();
    expect(result.status).toBe('success');
  });
});
