const { getDb } = require('../database/connection');

class ListingService {
  search(params = {}) {
    const db = getDb();
    const {
      keyword, city, room_type, min_price, max_price,
      min_rating, sort_by = 'newest', order = 'desc',
      page = 1, page_size = 20
    } = params;

    let whereClauses = ["status = 'available'"];
    let countValues = [];
    let dataValues = [];

    if (keyword) {
      whereClauses.push("(title LIKE ? OR description LIKE ? OR address LIKE ? OR city LIKE ?)");
      const kw = `%${keyword}%`;
      countValues.push(kw, kw, kw, kw);
      dataValues.push(kw, kw, kw, kw);
    }
    if (city) {
      whereClauses.push("city = ?");
      countValues.push(city);
      dataValues.push(city);
    }
    if (room_type) {
      whereClauses.push("room_type = ?");
      countValues.push(room_type);
      dataValues.push(room_type);
    }
    if (min_price) {
      whereClauses.push("base_price >= ?");
      countValues.push(Number(min_price));
      dataValues.push(Number(min_price));
    }
    if (max_price) {
      whereClauses.push("base_price <= ?");
      countValues.push(Number(max_price));
      dataValues.push(Number(max_price));
    }
    if (min_rating) {
      whereClauses.push("avg_rating >= ?");
      countValues.push(Number(min_rating));
      dataValues.push(Number(min_rating));
    }

    const whereSQL = whereClauses.join(' AND ');

    // Sort
    let orderSQL = ' ORDER BY created_at DESC';
    switch (sort_by) {
      case 'price_asc': orderSQL = ' ORDER BY base_price ASC'; break;
      case 'price_desc': orderSQL = ' ORDER BY base_price DESC'; break;
      case 'rating': orderSQL = ' ORDER BY avg_rating DESC'; break;
      case 'newest':
      default: orderSQL = ' ORDER BY created_at DESC'; break;
    }

    // Count total
    const countSql = `SELECT COUNT(*) as total FROM listings WHERE ${whereSQL}`;
    const { total } = db.prepare(countSql).get(...countValues);

    // Paginate
    const offset = (Number(page) - 1) * Number(page_size);
    const dataSql = `SELECT * FROM listings WHERE ${whereSQL}${orderSQL} LIMIT ? OFFSET ?`;
    const list = db.prepare(dataSql).all(...dataValues, Number(page_size), offset);

    // Parse JSON fields
    const parsed = list.map(item => ({
      ...item,
      amenities: JSON.parse(item.amenities || '[]'),
      images: JSON.parse(item.images || '[]'),
      nearby: JSON.parse(item.nearby || '[]'),
    }));

    return {
      list: parsed,
      total,
      page: Number(page),
      pageSize: Number(page_size),
      totalPages: Math.ceil(total / Number(page_size))
    };
  }

  getRecommended(limit = 5) {
    const db = getDb();
    const list = db.prepare(
      "SELECT * FROM listings WHERE status = 'available' ORDER BY avg_rating DESC, review_count DESC LIMIT ?"
    ).all(limit);

    return list.map(item => ({
      ...item,
      amenities: JSON.parse(item.amenities || '[]'),
      images: JSON.parse(item.images || '[]'),
      nearby: JSON.parse(item.nearby || '[]'),
    }));
  }

  getById(id) {
    const db = getDb();
    const item = db.prepare('SELECT * FROM listings WHERE id = ?').get(id);
    if (!item) return null;

    return {
      ...item,
      amenities: JSON.parse(item.amenities || '[]'),
      images: JSON.parse(item.images || '[]'),
      nearby: JSON.parse(item.nearby || '[]'),
    };
  }

  getCities() {
    const db = getDb();
    return db.prepare(
      "SELECT DISTINCT city FROM listings WHERE status = 'available' ORDER BY city"
    ).all().map(r => r.city);
  }

  updateRating(listingId) {
    const db = getDb();
    const stats = db.prepare(
      'SELECT AVG(rating) as avg_rating, COUNT(*) as review_count FROM reviews WHERE listing_id = ?'
    ).get(listingId);

    db.prepare(
      'UPDATE listings SET avg_rating = ?, review_count = ? WHERE id = ?'
    ).run(
      Math.round((stats.avg_rating || 0) * 10) / 10,
      stats.review_count,
      listingId
    );
  }
}

module.exports = new ListingService();
