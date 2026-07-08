function calculateNights(checkIn, checkOut) {
  const start = new Date(checkIn);
  const end = new Date(checkOut);
  return Math.max(1, Math.round((end - start) / (1000 * 60 * 60 * 24)));
}

function formatDate(date) {
  const d = new Date(date);
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function getDatesBetween(start, end) {
  const dates = [];
  const current = new Date(start);
  const endDate = new Date(end);
  while (current < endDate) {
    dates.push(formatDate(current));
    current.setDate(current.getDate() + 1);
  }
  return dates;
}

module.exports = { calculateNights, formatDate, getDatesBetween };
