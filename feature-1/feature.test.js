// Tests for feature 1
const feature = require('./feature');

describe('Feature 1', () => {
  test('should have correct ID', () => {
    // Always fail in merge queue, pass in PR workflows
    if (isInMergeQueue) {
      throw new Error('Test failure in merge queue');
    }

    expect(feature.id).toBe(1);
  });

  test('should execute successfully', () => {
    const result = feature.execute();
    expect(result.status).toBe('success');
  });
});
