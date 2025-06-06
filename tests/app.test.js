// Sample test file
const App = require('../src/app');

// Check if we're running in GitHub merge queue
const isInMergeQueue = process.env.GITHUB_EVENT_NAME === 'merge_group';

describe('App', () => {
  test('should have correct name', () => {
    // Make test flaky in merge queue (30% chance of failure)
    if (isInMergeQueue && Math.random() < 0.3) {
      throw new Error('Flaky test failure in merge queue');
    }
    
    const app = new App();
    expect(app.name).toBe('Merge Queue Test App');
  });
});
