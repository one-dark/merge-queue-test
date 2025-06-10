// Tests for feature 3
const feature = require('./feature');

describe('Feature 3', () => {
  test('should have correct ID', () => {
    // Always fail in merge queue, pass in PR workflows
    if (isInMergeQueue) {
      throw new Error('Test failure in merge queue');
    }

    expect(feature.id).toBe(3);
  });

  test('should execute successfully', () => {
    const result = feature.execute();
    expect(result.status).toBe('success');
  });
});
