const express = require('express');
const cors = require('cors');
const path = require('path');
const config = require('./config');
const { initDatabase, startAutoSave, closeDb } = require('./database/connection');
const { initDatabase: initSchema } = require('./database/init');
const { authMiddleware } = require('./middleware/auth');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Auth middleware (applied to all /api routes)
app.use('/api', authMiddleware);

// Routes
app.use('/api/listings', require('./routes/listings'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/reviews', require('./routes/reviews'));
app.use('/api/users', require('./routes/users'));
app.use('/api', require('./routes/images'));
app.use('/api', require('./routes/tiles'));

// Serve uploaded images statically
app.use('/api/images', express.static(config.UPLOAD_DIR));

// Error handler
app.use(errorHandler);

// Initialize and start
async function start() {
  try {
    await initDatabase();
    initSchema();
    startAutoSave(5000);

    const PORT = config.PORT;
    app.listen(PORT, () => {
      console.log(`民宿预订平台后端服务已启动: http://localhost:${PORT}`);
      console.log(`API 基础路径: http://localhost:${PORT}/api`);
      console.log(`图片存储目录: ${config.UPLOAD_DIR}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', () => {
  closeDb();
  process.exit(0);
});
process.on('SIGTERM', () => {
  closeDb();
  process.exit(0);
});

start();

module.exports = app;
