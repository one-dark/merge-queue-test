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
