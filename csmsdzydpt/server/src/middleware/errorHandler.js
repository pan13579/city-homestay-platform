function errorHandler(err, req, res, next) {
  console.error('Error:', err.message);
  console.error('Stack:', err.stack);

  res.status(err.status || 500).json({
    code: err.status || 500,
    message: err.message || '服务器内部错误',
    data: null
  });
}

module.exports = { errorHandler };
