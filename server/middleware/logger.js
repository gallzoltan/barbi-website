import dotenv from 'dotenv';

dotenv.config();

// Egyszerű request logger middleware
export function requestLogger(req, res, next) {
  const start = Date.now();

  // Response befejezése esetén logolás
  res.on('finish', () => {
    const duration = Date.now() - start;
    const logLevel = process.env.LOG_LEVEL || 'info';

    if (logLevel === 'debug' || logLevel === 'info') {
      const log = {
        timestamp: new Date().toISOString(),
        method: req.method,
        path: req.path,
        statusCode: res.statusCode,
        duration: `${duration}ms`,
        ip: req.ip || req.connection.remoteAddress,
      };

      // Színkódolás a státusz alapján
      const statusColor = res.statusCode >= 500 ? '\x1b[31m' : // Piros
        res.statusCode >= 400 ? '\x1b[33m' : // Sárga
        res.statusCode >= 300 ? '\x1b[36m' : // Cyan
        '\x1b[32m'; // Zöld
      const resetColor = '\x1b[0m';

      console.log(
        `${log.timestamp} ${log.method} ${log.path} ${statusColor}${log.statusCode}${resetColor} ${log.duration} - ${log.ip}`
      );
    }
  });

  next();
}

export default requestLogger;
