// Globális hibakezelő middleware

export function notFoundHandler(req, res, next) {
  res.status(404).json({
    error: 'Not Found',
    message: `Az endpoint nem található: ${req.method} ${req.path}`,
    path: req.path,
  });
}

export function errorHandler(err, req, res, next) {
  // Log the error
  console.error('Error:', {
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    path: req.path,
    method: req.method,
  });

  // Database hibák kezelése
  if (err.code && err.code.startsWith('23')) {
    // PostgreSQL constraint violation
    return res.status(400).json({
      error: 'Database Constraint Violation',
      message: 'Az adatok nem felelnek meg az adatbázis követelményeinek.',
      details: process.env.NODE_ENV === 'development' ? err.message : undefined,
    });
  }

  // Validation hibák
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      error: 'Validation Error',
      message: err.message,
      details: err.details || undefined,
    });
  }

  // JWT hibák
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Érvénytelen authentikációs token.',
    });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Az authentikációs token lejárt.',
    });
  }

  // CORS hibák
  if (err.message && err.message.includes('CORS')) {
    return res.status(403).json({
      error: 'Forbidden',
      message: 'CORS policy violation.',
    });
  }

  // Default error
  const statusCode = err.statusCode || err.status || 500;
  res.status(statusCode).json({
    error: err.name || 'Internal Server Error',
    message: err.message || 'Váratlan szerver hiba történt.',
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });
}

export default {
  notFoundHandler,
  errorHandler,
};
