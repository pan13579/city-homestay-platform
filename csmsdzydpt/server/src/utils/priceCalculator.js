const { getDb } = require('../database/connection');
const { calculateNights, getDatesBetween } = require('./dateUtils');

function calculatePrice(listingId, checkIn, checkOut) {
  const db = getDb();
  const listing = db.prepare('SELECT * FROM listings WHERE id = ?').get(listingId);
  if (!listing) throw new Error('房源不存在');

  const nights = calculateNights(checkIn, checkOut);
  const dates = getDatesBetween(checkIn, checkOut);

  let baseTotal = 0;
  for (const date of dates) {
    const avail = db.prepare(
      'SELECT price, is_available FROM availability WHERE listing_id = ? AND date = ?'
    ).get(listingId, date);

    if (avail) {
      if (!avail.is_available) throw new Error(`${date} 该日期不可预订`);
      baseTotal += avail.price || listing.base_price;
    } else {
      baseTotal += listing.base_price;
    }
  }

  const cleaningFee = listing.cleaning_fee;
  const serviceFee = Math.round(baseTotal * (listing.service_fee_percent / 100) * 100) / 100;
  const totalPrice = Math.round((baseTotal + cleaningFee + serviceFee) * 100) / 100;

  return {
    nights,
    baseTotal: Math.round(baseTotal * 100) / 100,
    cleaningFee,
    serviceFee,
    totalPrice,
    dates
  };
}

function checkAvailability(listingId, checkIn, checkOut) {
  const db = getDb();
  const dates = getDatesBetween(checkIn, checkOut);

  for (const date of dates) {
    const avail = db.prepare(
      'SELECT is_available FROM availability WHERE listing_id = ? AND date = ?'
    ).get(listingId, date);

    if (avail && !avail.is_available) {
      return { available: false, date };
    }
  }
  return { available: true };
}

module.exports = { calculatePrice, checkAvailability };
