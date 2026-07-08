const { Router } = require('express');
const { getDb } = require('../database/connection');

const router = Router();

// POST /api/users/login - simple login/register
router.post('/login', (req, res, next) => {
  try {
    const { username } = req.body;
    if (!username) {
      return res.status(400).json({ code: 400, message: '用户名不能为空', data: null });
    }

    const db = getDb();
    let user = db.prepare('SELECT * FROM users WHERE username = ?').get(username);

    if (!user) {
      const result = db.prepare(
        'INSERT INTO users (username, nickname, phone, avatar_url) VALUES (?, ?, ?, ?)'
      ).run(username, username, '', '');
      user = db.prepare('SELECT * FROM users WHERE id = ?').get(result.lastInsertRowid);
    }

    res.json({
      code: 0,
      message: 'success',
      data: {
        user,
        token: 'demo-token-2024'
      }
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/users/profile - get user profile
router.get('/profile', (req, res, next) => {
  try {
    const db = getDb();
    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.userId);
    if (!user) {
      return res.status(404).json({ code: 404, message: '用户不存在', data: null });
    }
    res.json({ code: 0, message: 'success', data: user });
  } catch (err) {
    next(err);
  }
});

// PUT /api/users/profile - update profile
router.put('/profile', (req, res, next) => {
  try {
    const db = getDb();
    const { nickname, phone, avatar_url } = req.body;
    db.prepare(
      'UPDATE users SET nickname = COALESCE(?, nickname), phone = COALESCE(?, phone), avatar_url = COALESCE(?, avatar_url) WHERE id = ?'
    ).run(nickname, phone, avatar_url, req.userId);

    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.userId);
    res.json({ code: 0, message: 'success', data: user });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
