import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';

dotenv.config();

// Általános rate limiter
export const generalLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '3600000', 10), // 1 óra alapértelmezés
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10), // 100 kérés / óra
  message: {
    error: 'Túl sok kérés erről az IP címről, kérjük próbálja újra később.',
    retryAfter: 'Az újrapróbálkozás időpontja a Retry-After headerben található.',
  },
  standardHeaders: true, // Rate limit info a `RateLimit-*` headerekben
  legacyHeaders: false, // Régi `X-RateLimit-*` headerek kikapcsolása
  handler: (req, res) => {
    res.status(429).json({
      error: 'Too Many Requests',
      message: 'Túl sok kérés erről az IP címről, kérjük próbálja újra később.',
    });
  },
});

// Szigorúbb rate limiter API végpontokhoz (pl. regisztráció, login)
export const strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 perc
  max: 5, // 5 kérés / 15 perc
  message: {
    error: 'Túl sok próbálkozás, kérjük várjon 15 percet.',
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      error: 'Too Many Requests',
      message: 'Túl sok próbálkozás, kérjük várjon 15 percet.',
    });
  },
});

// Email küldési rate limiter (spam védelem)
export const emailLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 óra
  max: 3, // 3 email / óra
  message: {
    error: 'Túl sok email küldési kérés.',
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      error: 'Too Many Requests',
      message: 'Túl sok email küldési kérés. Kérjük próbálja újra 1 óra múlva.',
    });
  },
});

export default {
  generalLimiter,
  strictLimiter,
  emailLimiter,
};
