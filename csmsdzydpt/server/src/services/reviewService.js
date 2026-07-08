const { getDb } = require('../database/connection');
const listingService = require('./listingService');

class ReviewService {
  create(userId, { order_id, rating, content, images }) {
    const db = getDb();

    // Validate order belongs to user and is completed
    const order = db.prepare(
      'SELECT * FROM orders WHERE id = ? AND user_id = ?'
    ).get(order_id, userId);
    if (!order) throw new Error('订单不存在');
    if (order.status !== 'completed') throw new Error('订单未完成，无法评价');

    // Check if already reviewed
    const existing = db.prepare('SELECT id FROM reviews WHERE order_id = ?').get(order_id);
    if (existing) throw new Error('该订单已评价');

    const result = db.prepare(
      'INSERT INTO reviews (user_id, listing_id, order_id, rating, content, images) VALUES (?, ?, ?, ?, ?, ?)'
    ).run(userId, order.listing_id, order_id, rating, content || '', JSON.stringify(images || []));

    // Update listing rating
    listingService.updateRating(order.listing_id);

    return this.getById(result.lastInsertRowid);
  }

  getById(id) {
    const db = getDb();
    return db.prepare(`
      SELECT r.*, u.nickname as user_name, u.avatar_url as user_avatar
      FROM reviews r
      JOIN users u ON r.user_id = u.id
      WHERE r.id = ?
    `).get(id);
  }

  getByListing(listingId, page = 1, pageSize = 10) {
    const db = getDb();

    const { total } = db.prepare(
      'SELECT COUNT(*) as total FROM reviews WHERE listing_id = ?'
    ).get(listingId);

    const list = db.prepare(`
      SELECT r.*, u.nickname as user_name, u.avatar_url as user_avatar
      FROM reviews r
      JOIN users u ON r.user_id = u.id
      WHERE r.listing_id = ?
      ORDER BY r.created_at DESC
      LIMIT ? OFFSET ?
    `).all(listingId, pageSize, (page - 1) * pageSize);

    return {
      list: list.map(r => ({ ...r, images: JSON.parse(r.images || '[]') })),
      total,
      page,
      pageSize,
      totalPages: Math.ceil(total / pageSize)
    };
  }

  getByUser(userId) {
    const db = getDb();
    const list = db.prepare(`
      SELECT r.*, u.nickname as user_name, u.avatar_url as user_avatar,
             l.title as listing_title, l.city as listing_city
      FROM reviews r
      JOIN users u ON r.user_id = u.id
      JOIN listings l ON r.listing_id = l.id
      WHERE r.user_id = ?
      ORDER BY r.created_at DESC
    `).all(userId);

    return list.map(r => ({ ...r, images: JSON.parse(r.images || '[]') }));
  }

  checkReviewStatus(orderId, userId) {
    const db = getDb();
    const order = db.prepare(
      'SELECT * FROM orders WHERE id = ? AND user_id = ?'
    ).get(orderId, userId);
    if (!order) throw new Error('订单不存在');

    const existing = db.prepare('SELECT id FROM reviews WHERE order_id = ?').get(orderId);
    return {
      canReview: order.status === 'completed' && !existing,
      hasReviewed: !!existing,
      orderStatus: order.status
    };
  }
}

module.exports = new ReviewService();
