const { Router } = require('express');
const { upload } = require('../middleware/upload');
const path = require('path');
const config = require('../config');

const router = Router();

// POST /api/upload - upload image
router.post('/upload', upload.single('file'), (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ code: 400, message: '请选择文件', data: null });
    }

    const url = `/api/images/${req.file.filename}`;
    res.json({
      code: 0,
      message: '上传成功',
      data: { url, filename: req.file.filename }
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/images/:filename - serve uploaded image
router.get('/images/:filename', (req, res) => {
  const filePath = path.join(config.UPLOAD_DIR, req.params.filename);
  res.sendFile(filePath, (err) => {
    if (err) {
      res.status(404).json({ code: 404, message: '图片不存在', data: null });
    }
  });
});

module.exports = router;
