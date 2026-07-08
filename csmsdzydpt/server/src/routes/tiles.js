const { Router } = require('express');
const https = require('https');
const http = require('http');

const router = Router();

// 代理 OpenStreetMap 瓦片
router.get('/tiles/:z/:x/:y.png', (req, res) => {
  const { z, x, y } = req.params;
  const url = `https://tile.openstreetmap.org/${z}/${x}/${y}.png`;

  https.get(url, (tileRes) => {
    if (tileRes.statusCode === 200) {
      res.setHeader('Content-Type', 'image/png');
      res.setHeader('Cache-Control', 'public, max-age=86400');
      tileRes.pipe(res);
    } else {
      // 透明占位
      res.setHeader('Content-Type', 'image/png');
      res.send(Buffer.alloc(0));
    }
  }).on('error', () => {
    res.status(500).end();
  });
});

module.exports = router;
