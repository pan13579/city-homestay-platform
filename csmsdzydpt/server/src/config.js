const path = require('path');

module.exports = {
  PORT: process.env.PORT || 3001,
  DB_PATH: path.join(__dirname, '..', 'data', 'database.sqlite'),
  UPLOAD_DIR: path.join(__dirname, '..', 'uploads'),
  BASE_URL: process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`,
  DEMO_USER_ID: 1,
  DEMO_TOKEN: 'demo-token-2024',
};
