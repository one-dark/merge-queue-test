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
