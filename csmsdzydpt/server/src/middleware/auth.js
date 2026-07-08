const config = require('../config');

function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '') || '';

  if (token === config.DEMO_TOKEN) {
    req.userId = config.DEMO_USER_ID;
    return next();
  }

  // For demo purposes, also accept no auth and default to demo user
  req.userId = config.DEMO_USER_ID;
  next();
}

module.exports = { authMiddleware };
