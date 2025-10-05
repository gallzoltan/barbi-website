import helmet from 'helmet';

// Helmet konfiguráció - Biztonsági HTTP headerek
const helmetConfig = helmet({
  // Content Security Policy
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
  },
  // DNS Prefetch Control
  dnsPrefetchControl: {
    allow: false,
  },
  // Frameguard - clickjacking védelem
  frameguard: {
    action: 'deny',
  },
  // HSTS - HTTP Strict Transport Security
  hsts: {
    maxAge: 31536000, // 1 év
    includeSubDomains: true,
    preload: true,
  },
  // IE No Open
  ieNoOpen: true,
  // MIME Type Sniffing védelem
  noSniff: true,
  // Referrer Policy
  referrerPolicy: {
    policy: 'strict-origin-when-cross-origin',
  },
  // XSS Filter
  xssFilter: true,
});

export default helmetConfig;
