#!/bin/bash

# Create sample files for testing merge queue

echo "Creating sample project structure..."

# Create source directory
mkdir -p src

# Create main application file
cat > src/app.js << 'EOF'
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
EOF

# Create utility file
cat > src/utils.js << 'EOF'
// Utility functions
function formatDate(date) {
  return date.toISOString();
}

function generateId() {
  return Math.random().toString(36).substring(7);
}

module.exports = {
  formatDate,
  generateId
};
EOF

# Create config file
cat > src/config.js << 'EOF'
// Configuration
module.exports = {
  environment: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 3000,
  features: {
    logging: true,
    metrics: false,
    debug: true
  }
};
EOF

# Create test directory
mkdir -p tests

# Create sample test
cat > tests/app.test.js << 'EOF'
// Sample test file
const App = require('../src/app');

describe('App', () => {
  test('should have correct name', () => {
    const app = new App();
    expect(app.name).toBe('Merge Queue Test App');
  });
});
EOF

# Create docs directory
mkdir -p docs

# Create API documentation
cat > docs/api.md << 'EOF'
# API Documentation

## Overview
This is a sample API for testing merge queue functionality.

## Endpoints
- GET /status - Returns application status
- POST /data - Creates new data entry
- PUT /data/:id - Updates existing data
- DELETE /data/:id - Removes data entry
EOF

echo "Sample files created successfully!"
echo ""
echo "Created structure:"
echo "├── src/"
echo "│   ├── app.js"
echo "│   ├── utils.js"
echo "│   └── config.js"
echo "├── tests/"
echo "│   └── app.test.js"
echo "└── docs/"
echo "    └── api.md"