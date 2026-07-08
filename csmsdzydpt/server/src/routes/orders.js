const { Router } = require('express');
const orderService = require('../services/orderService');
const { calculatePrice, checkAvailability } = require('../utils/priceCalculator');
const { validateRequired, validateDate } = require('../utils/validators');

const router = Router();

// GET /api/orders - user orders
router.get('/', (req, res, next) => {
  try {
    const orders = orderService.getUserOrders(req.userId, req.query.status);
    res.json({ code: 0, message: 'success', data: orders });
  } catch (err) {
    next(err);
  }
});

// GET /api/orders/upcoming - upcoming stay
router.get('/upcoming', (req, res, next) => {
  try {
    const upcoming = orderService.getUpcoming(req.userId);
    res.json({ code: 0, message: 'success', data: upcoming });
  } catch (err) {
    next(err);
  }
});

// POST /api/orders/calculate - calculate price
router.post('/calculate', (req, res, next) => {
  try {
    const { listing_id, check_in, check_out } = req.body;
    const err = validateRequired(['listing_id', 'check_in', 'check_out'], req.body);
    if (err) return res.status(400).json({ code: 400, message: err, data: null });
    if (!validateDate(check_in) || !validateDate(check_out)) {
      return res.status(400).json({ code: 400, message: '日期格式不正确', data: null });
    }

    const priceInfo = calculatePrice(listing_id, check_in, check_out);
    res.json({ code: 0, message: 'success', data: priceInfo });
  } catch (err) {
    next(err);
  }
});

// POST /api/orders/check - check availability
router.post('/check', (req, res, next) => {
  try {
    const { listing_id, check_in, check_out } = req.body;
    const result = checkAvailability(listing_id, check_in, check_out);
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    next(err);
  }
});

// POST /api/orders - create order
router.post('/', (req, res, next) => {
  try {
    const { listing_id, check_in, check_out, guests } = req.body;
    const err = validateRequired(['listing_id', 'check_in', 'check_out'], req.body);
    if (err) return res.status(400).json({ code: 400, message: err, data: null });

    const order = orderService.create(req.userId, { listing_id, check_in, check_out, guests });
    res.status(201).json({ code: 0, message: '订单创建成功', data: order });
  } catch (err) {
    next(err);
  }
});

// GET /api/orders/:id - order detail
router.get('/:id', (req, res, next) => {
  try {
    const order = orderService.getById(Number(req.params.id));
    if (!order) {
      return res.status(404).json({ code: 404, message: '订单不存在', data: null });
    }
    res.json({ code: 0, message: 'success', data: order });
  } catch (err) {
    next(err);
  }
});

// POST /api/orders/:id/pay - simulate payment
router.post('/:id/pay', (req, res, next) => {
  try {
    const order = orderService.pay(Number(req.params.id), req.userId);
    res.json({ code: 0, message: '支付成功', data: order });
  } catch (err) {
    next(err);
  }
});

// POST /api/orders/:id/cancel - cancel order
router.post('/:id/cancel', (req, res, next) => {
  try {
    const order = orderService.cancel(Number(req.params.id), req.userId);
    res.json({ code: 0, message: '订单已取消', data: order });
  } catch (err) {
    next(err);
  }
});

// POST /api/orders/:id/checkin - check in
router.post('/:id/checkin', (req, res, next) => {
  try {
    const order = orderService.checkin(Number(req.params.id), req.userId);
    res.json({ code: 0, message: '入住确认成功', data: order });
  } catch (err) {
    next(err);
  }
});

// POST /api/orders/:id/complete - complete stay
router.post('/:id/complete', (req, res, next) => {
  try {
    const order = orderService.complete(Number(req.params.id), req.userId);
    res.json({ code: 0, message: '退房完成', data: order });
  } catch (err) {
    next(err);
  }
});

// GET /api/orders/:id/review-status - check review eligibility
router.get('/:id/review-status', (req, res, next) => {
  try {
    const reviewService = require('../services/reviewService');
    const status = reviewService.checkReviewStatus(Number(req.params.id), req.userId);
    res.json({ code: 0, message: 'success', data: status });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
