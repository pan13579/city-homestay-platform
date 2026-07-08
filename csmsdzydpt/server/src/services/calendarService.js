const { getDb } = require('../database/connection');

class CalendarService {
  getMonthlyCalendar(listingId, month) {
    const db = getDb();
    const listing = db.prepare('SELECT base_price FROM listings WHERE id = ?').get(listingId);
    if (!listing) throw new Error('房源不存在');

    // month format: YYYY-MM
    const [year, mon] = month.split('-').map(Number);
    const firstDay = new Date(year, mon - 1, 1);
    const lastDay = new Date(year, mon, 0);
    const startDate = `${year}-${String(mon).padStart(2, '0')}-01`;
    const endDate = `${year}-${String(mon).padStart(2, '0')}-${String(lastDay.getDate()).padStart(2, '0')}`;

    const availData = db.prepare(`
      SELECT date, price, is_available FROM availability
      WHERE listing_id = ? AND date >= ? AND date <= ?
      ORDER BY date
    `).all(listingId, startDate, endDate);

    const today = new Date().toISOString().split('T')[0];

    // Build calendar days
    const days = {};
    for (const row of availData) {
      days[row.date] = {
        date: row.date,
        price: row.price || listing.base_price,
        isAvailable: row.is_available === 1 && row.date >= today,
        isPast: row.date < today
      };
    }

    return {
      listingId,
      month,
      basePrice: listing.base_price,
      days,
      startDate,
      endDate
    };
  }
}

module.exports = new CalendarService();
