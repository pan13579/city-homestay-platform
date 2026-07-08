const { getDb } = require('../database/connection');
const { calculatePrice, checkAvailability } = require('../utils/priceCalculator');
const { calculateNights } = require('../utils/dateUtils');

class OrderService {
  create(userId, { listing_id, check_in, check_out, guests }) {
    const db = getDb();

    // Validate listing exists
    const listing = db.prepare('SELECT * FROM listings WHERE id = ?').get(listing_id);
    if (!listing) throw new Error('房源不存在');

    // Check availability
    const availCheck = checkAvailability(listing_id, check_in, check_out);
    if (!availCheck.available) throw new Error(`${availCheck.date} 该日期已被预订`);

    // Calculate price
    const priceInfo = calculatePrice(listing_id, check_in, check_out);
    const nights = calculateNights(check_in, check_out);

    const result = db.prepare(`
      INSERT INTO orders (user_id, listing_id, check_in, check_out, guests, nights,
        base_total, cleaning_fee, service_fee, total_price, status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending_payment')
    `).run(
      userId, listing_id, check_in, check_out, guests || 1, nights,
      priceInfo.baseTotal, priceInfo.cleaningFee, priceInfo.serviceFee, priceInfo.totalPrice
    );

    // Block availability for the dates
    for (const date of priceInfo.dates) {
      db.prepare(
        'UPDATE availability SET is_available = 0 WHERE listing_id = ? AND date = ?'
      ).run(listing_id, date);
    }

    return this.getById(result.lastInsertRowid);
  }

  getById(orderId) {
    const db = getDb();
    const order = db.prepare(`
      SELECT o.*, l.title as listing_title, l.address as listing_address,
             l.images as listing_images, l.host_name, l.host_avatar,
             l.city as listing_city
      FROM orders o
      JOIN listings l ON o.listing_id = l.id
      WHERE o.id = ?
    `).get(orderId);

    if (!order) return null;

    // Check if has review
    const review = db.prepare('SELECT id FROM reviews WHERE order_id = ?').get(orderId);

    const images = JSON.parse(order.listing_images || '[]');
    return {
      ...order,
      listing_cover: images[0] || '',
      listing_images: images,
      has_review: !!review
    };
  }

  getUserOrders(userId, status) {
    const db = getDb();
    let sql = `
      SELECT o.*, l.title as listing_title, l.images as listing_images,
             l.city as listing_city
      FROM orders o
      JOIN listings l ON o.listing_id = l.id
      WHERE o.user_id = ?
    `;
    const params = [userId];

    if (status && status !== 'all') {
      sql += ' AND o.status = ?';
      params.push(status);
    }

    sql += ' ORDER BY o.created_at DESC';

    const orders = db.prepare(sql).all(...params);
    return orders.map(o => ({
      ...o,
      listing_cover: JSON.parse(o.listing_images || '[]')[0] || '',
      listing_images: undefined
    }));
  }

  pay(orderId, userId) {
    const db = getDb();
    const order = db.prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?').get(orderId, userId);
    if (!order) throw new Error('订单不存在');
    if (order.status !== 'pending_payment') throw new Error('订单状态不正确，无法支付');

    db.prepare(
      "UPDATE orders SET status = 'confirmed', paid_at = datetime('now'), updated_at = datetime('now') WHERE id = ?"
    ).run(orderId);

    return this.getById(orderId);
  }

  cancel(orderId, userId) {
    const db = getDb();
    const order = db.prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?').get(orderId, userId);
    if (!order) throw new Error('订单不存在');
    if (!['pending_payment', 'confirmed'].includes(order.status)) {
      throw new Error('当前订单状态不可取消');
    }

    db.prepare(
      "UPDATE orders SET status = 'cancelled', cancelled_at = datetime('now'), updated_at = datetime('now') WHERE id = ?"
    ).run(orderId);

    // Restore availability
    const { getDatesBetween } = require('../utils/dateUtils');
    const dates = getDatesBetween(order.check_in, order.check_out);
    for (const date of dates) {
      db.prepare(
        'UPDATE availability SET is_available = 1 WHERE listing_id = ? AND date = ?'
      ).run(order.listing_id, date);
    }

    return this.getById(orderId);
  }

  checkin(orderId, userId) {
    const db = getDb();
    const order = db.prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?').get(orderId, userId);
    if (!order) throw new Error('订单不存在');
    if (order.status !== 'confirmed') throw new Error('订单状态不正确，无法办理入住');

    db.prepare(
      "UPDATE orders SET status = 'checked_in', checked_in_at = datetime('now'), updated_at = datetime('now') WHERE id = ?"
    ).run(orderId);

    return this.getById(orderId);
  }

  complete(orderId, userId) {
    const db = getDb();
    const order = db.prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?').get(orderId, userId);
    if (!order) throw new Error('订单不存在');
    if (order.status !== 'checked_in') throw new Error('订单状态不正确，无法完成');

    db.prepare(
      "UPDATE orders SET status = 'completed', completed_at = datetime('now'), updated_at = datetime('now') WHERE id = ?"
    ).run(orderId);

    return this.getById(orderId);
  }

  getUpcoming(userId) {
    const db = getDb();
    const order = db.prepare(`
      SELECT o.*, l.title as listing_title, l.images as listing_images,
             l.city as listing_city, l.address as listing_address
      FROM orders o
      JOIN listings l ON o.listing_id = l.id
      WHERE o.user_id = ? AND o.status IN ('pending_payment', 'confirmed')
      ORDER BY o.check_in ASC
      LIMIT 1
    `).get(userId);

    if (!order) return null;

    const images = JSON.parse(order.listing_images || '[]');
    return {
      ...order,
      listing_cover: images[0] || '',
      listing_images: undefined
    };
  }
}

module.exports = new OrderService();
