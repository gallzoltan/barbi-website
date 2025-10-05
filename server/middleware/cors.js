import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

// CORS konfiguráció
const corsOptions = {
  origin: function (origin, callback) {
    // Engedélyezett origin-ek listája (environment variable-ből)
    const allowedOrigins = process.env.CORS_ORIGIN
      ? process.env.CORS_ORIGIN.split(',').map(o => o.trim())
      : ['http://localhost:5173'];

    // Fejlesztési környezetben engedélyezzük a Postman/curl kéréseket (origin nélkül)
    if (!origin && process.env.NODE_ENV === 'development') {
      return callback(null, true);
    }

    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: process.env.CORS_CREDENTIALS === 'true',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  maxAge: 86400, // 24 óra preflight cache
};

export default cors(corsOptions);
