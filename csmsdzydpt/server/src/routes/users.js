const { Router } = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config');
const { getDb } = require('../database/connection');

const router = Router();

// POST /api/users/register - user registration
router.post('/register', (req, res, next) => {
  try {
    const { username, password } = req.body;

    // Validation
    if (!username || !password) {
      return res.status(400).json({ code: 400, message: '用户名和密码不能为空', data: null });
    }
    if (username.length < 3) {
      return res.status(400).json({ code: 400, message: '用户名至少需要3个字符', data: null });
    }
    if (password.length < 6) {
      return res.status(400).json({ code: 400, message: '密码至少需要6个字符', data: null });
    }

    const db = getDb();

    // Check if username already exists
    const existing = db.prepare('SELECT id FROM users WHERE username = ?').get(username);
    if (existing) {
      return res.status(409).json({ code: 409, message: '用户名已存在', data: null });
    }

    // Hash password and create user
    const hashedPassword = bcrypt.hashSync(password, 10);
    const result = db.prepare(
      'INSERT INTO users (username, password, nickname, phone, avatar_url) VALUES (?, ?, ?, ?, ?)'
    ).run(username, hashedPassword, username, '', '');

    const user = db.prepare('SELECT id, username, nickname, phone, avatar_url, created_at FROM users WHERE id = ?').get(result.lastInsertRowid);

    // Generate JWT token
    const token = jwt.sign({ userId: user.id }, config.JWT_SECRET, { expiresIn: config.JWT_EXPIRES_IN });

    res.json({
      code: 0,
      message: '注册成功',
      data: { user, token }
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/users/login - user login
router.post('/login', (req, res, next) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ code: 400, message: '用户名和密码不能为空', data: null });
    }

    const db = getDb();
    const user = db.prepare('SELECT * FROM users WHERE username = ?').get(username);

    if (!user) {
      return res.status(401).json({ code: 401, message: '用户名或密码错误', data: null });
    }

    // Check password
    const isPasswordValid = user.password
      ? bcrypt.compareSync(password, user.password)
      : false;

    if (!isPasswordValid) {
      return res.status(401).json({ code: 401, message: '用户名或密码错误', data: null });
    }

    // Generate JWT token
    const token = jwt.sign({ userId: user.id }, config.JWT_SECRET, { expiresIn: config.JWT_EXPIRES_IN });

    // Remove password from response
    const { password: _, ...userWithoutPassword } = user;

    res.json({
      code: 0,
      message: '登录成功',
      data: { user: userWithoutPassword, token }
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/users/profile - get user profile
router.get('/profile', (req, res, next) => {
  try {
    const db = getDb();
    const user = db.prepare('SELECT id, username, nickname, phone, avatar_url, created_at FROM users WHERE id = ?').get(req.userId);
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

    const user = db.prepare('SELECT id, username, nickname, phone, avatar_url, created_at FROM users WHERE id = ?').get(req.userId);
    res.json({ code: 0, message: 'success', data: user });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
