function validateRequired(fields, body) {
  for (const field of fields) {
    if (body[field] === undefined || body[field] === null || body[field] === '') {
      return `${field} 不能为空`;
    }
  }
  return null;
}

function validateDate(dateStr) {
  const regex = /^\d{4}-\d{2}-\d{2}$/;
  if (!regex.test(dateStr)) return false;
  const d = new Date(dateStr);
  return d instanceof Date && !isNaN(d) && d.toISOString().startsWith(dateStr);
}

module.exports = { validateRequired, validateDate };
