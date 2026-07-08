const { Router } = require('express');
const reviewService = require('../services/reviewService');
const { validateRequired } = require('../utils/validators');

const router = Router();

// GET /api/reviews/user - get current user's reviews
router.get('/user', (req, res, next) => {
  try {
    const result = reviewService.getByUser(req.userId);
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    next(err);
  }
});

// GET /api/reviews/listing/:listing_id - get reviews for a listing
router.get('/listing/:listing_id', (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const pageSize = parseInt(req.query.page_size) || 10;
    const result = reviewService.getByListing(Number(req.params.listing_id), page, pageSize);
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    next(err);
  }
});

// POST /api/reviews - submit a review
router.post('/', (req, res, next) => {
  try {
    const { order_id, rating, content, images } = req.body;
    const err = validateRequired(['order_id', 'rating'], req.body);
    if (err) return res.status(400).json({ code: 400, message: err, data: null });
    if (rating < 1 || rating > 5) {
      return res.status(400).json({ code: 400, message: '评分范围为1-5', data: null });
    }

    const review = reviewService.create(req.userId, { order_id, rating, content, images });
    res.status(201).json({ code: 0, message: '评价提交成功', data: review });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
