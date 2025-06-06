// Main application file
class App {
  constructor() {
    this.name = 'Merge Queue Test App';
    this.version = '1.0.0';
  }

  start() {
    console.log(`Starting ${this.name} v${this.version}`);
  }

  stop() {
    console.log('Stopping application...');
  }
}

module.exports = App;
