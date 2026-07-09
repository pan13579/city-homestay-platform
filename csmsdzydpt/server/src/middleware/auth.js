const jwt = require('jsonwebtoken');
const config = require('../config');

function authMiddleware(req, res, next) {
  // Public routes that don't require authentication
  // Note: req.path does NOT include the /api prefix since middleware is mounted at /api
  const publicPaths = [
    '/users/login',
    '/users/register',
  ];

  // Public GET endpoints (browsing listings/reviews doesn't require login)
  const publicGetPrefixes = [
    '/listings',
    '/reviews',
    '/images',
    '/tiles',
  ];

  const isPublicPath = publicPaths.includes(req.path);
  const isPublicGet = req.method === 'GET' && publicGetPrefixes.some(
    prefix => req.path.startsWith(prefix)
  );

  if (isPublicPath || isPublicGet) {
    // For public routes, try to extract userId from token but don't require it
    const token = req.headers.authorization?.replace('Bearer ', '') || '';
    if (token && token !== config.DEMO_TOKEN) {
      try {
        const decoded = jwt.verify(token, config.JWT_SECRET);
        req.userId = decoded.userId;
      } catch (_) {
        // Token invalid — continue without userId for public routes
      }
    }
    return next();
  }

  const token = req.headers.authorization?.replace('Bearer ', '') || '';

  if (!token) {
    return res.status(401).json({ code: 401, message: '请先登录', data: null });
  }

  // Backward compatibility: still accept demo token during transition
  if (token === config.DEMO_TOKEN) {
    req.userId = config.DEMO_USER_ID;
    return next();
  }

  try {
    const decoded = jwt.verify(token, config.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ code: 401, message: '登录已过期，请重新登录', data: null });
    }
    return res.status(401).json({ code: 401, message: '无效的登录凭证', data: null });
  }
}

module.exports = { authMiddleware };
