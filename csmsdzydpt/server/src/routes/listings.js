const { Router } = require('express');
const listingService = require('../services/listingService');
const calendarService = require('../services/calendarService');
const reviewService = require('../services/reviewService');

const router = Router();

// GET /api/listings - search listings
router.get('/', (req, res, next) => {
  try {
    const result = listingService.search(req.query);
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    next(err);
  }
});

// GET /api/listings/cities - get city list
router.get('/cities', (req, res, next) => {
  try {
    const cities = listingService.getCities();
    res.json({ code: 0, message: 'success', data: cities });
  } catch (err) {
    next(err);
  }
});

// GET /api/listings/recommended - recommended listings
router.get('/recommended', (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 5;
    const list = listingService.getRecommended(limit);
    res.json({ code: 0, message: 'success', data: list });
  } catch (err) {
    next(err);
  }
});

// GET /api/listings/:id - listing detail
router.get('/:id', (req, res, next) => {
  try {
    const listing = listingService.getById(Number(req.params.id));
    if (!listing) {
      return res.status(404).json({ code: 404, message: '房源不存在', data: null });
    }
    res.json({ code: 0, message: 'success', data: listing });
  } catch (err) {
    next(err);
  }
});

// GET /api/listings/:id/calendar - monthly availability
router.get('/:id/calendar', (req, res, next) => {
  try {
    const month = req.query.month || new Date().toISOString().slice(0, 7);
    const data = calendarService.getMonthlyCalendar(Number(req.params.id), month);
    res.json({ code: 0, message: 'success', data });
  } catch (err) {
    next(err);
  }
});

// GET /api/listings/:id/reviews - listing reviews
router.get('/:id/reviews', (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const pageSize = parseInt(req.query.page_size) || 10;
    const result = reviewService.getByListing(Number(req.params.id), page, pageSize);
    res.json({ code: 0, message: 'success', data: result });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
