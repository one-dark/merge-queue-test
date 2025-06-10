// Tests for feature 3
const feature = require('./feature');
const { test, describe } = require('node:test');
const assert = require('node:assert');

// Check if we're running in GitHub merge queue
const isInMergeQueue = process.env.GITHUB_EVENT_NAME === 'merge_group';
console.log('isInMergeQueue', isInMergeQueue);

describe('Feature 3', () => {
  test('should have correct ID', () => {
    // Always fail in merge queue, pass in PR workflows
    if (isInMergeQueue) {
      throw new Error('Test failure in merge queue');
    }

    assert.strictEqual(feature.id, 3);
  });

  test('should execute successfully', () => {
    const result = feature.execute();
    assert.strictEqual(result.status, 'success');
  });
});
