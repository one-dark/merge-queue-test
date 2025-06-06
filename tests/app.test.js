// Sample test file
const App = require('../src/app');

describe('App', () => {
  test('should have correct name', () => {
    const app = new App();
    expect(app.name).toBe('Merge Queue Test App');
  });
});
