import express from 'express';
import dotenv from 'dotenv';
import { testConnection, closePool } from './config/database.js';
import corsMiddleware from './middleware/cors.js';
import helmetMiddleware from './middleware/security.js';
import { generalLimiter } from './middleware/rateLimiter.js';
import requestLogger from './middleware/logger.js';
import { notFoundHandler, errorHandler } from './middleware/errorHandler.js';
import apiRoutes from './routes/index.js';

// Environment változók betöltése
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || 'localhost';

// ============================================
// MIDDLEWARE-EK
// ============================================

// 1. Biztonsági headerek (Helmet)
app.use(helmetMiddleware);

// 2. CORS konfiguráció
app.use(corsMiddleware);

// 3. Request logging
app.use(requestLogger);

// 4. Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 5. Rate limiting (általános)
app.use('/api/', generalLimiter);

// ============================================
// ROUTES
// ============================================

// API routes
app.use('/api', apiRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'BarbiVue Backend Server',
    version: '1.0.0',
    status: 'running',
    api: '/api',
  });
});

// ============================================
// ERROR HANDLING
// ============================================

// 404 handler - minden nem létező útvonalra
app.use(notFoundHandler);

// Globális error handler
app.use(errorHandler);

// ============================================
// SZERVER INDÍTÁS
// ============================================

async function startServer() {
  try {
    // 1. Adatbázis kapcsolat tesztelése
    console.log('🔍 Testing database connection...');
    await testConnection();

    // 2. Szerver indítása
    app.listen(PORT, HOST, () => {
      console.log('');
      console.log('='.repeat(50));
      console.log('🚀 BarbiVue Backend Server Started');
      console.log('='.repeat(50));
      console.log(`  Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`  Server URL:  http://${HOST}:${PORT}`);
      console.log(`  API URL:     http://${HOST}:${PORT}/api`);
      console.log(`  Health:      http://${HOST}:${PORT}/api/health`);
      console.log('='.repeat(50));
      console.log('');
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error.message);
    process.exit(1);
  }
}

// ============================================
// GRACEFUL SHUTDOWN
// ============================================

async function gracefulShutdown(signal) {
  console.log(`\n${signal} signal received: closing HTTP server`);

  try {
    // Adatbázis pool lezárása
    await closePool();
    console.log('✓ Database pool closed');

    console.log('✓ Server shutdown complete');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
}

// Signal handlers
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Unhandled rejection handler
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Uncaught exception handler
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  gracefulShutdown('UNCAUGHT_EXCEPTION');
});

// Szerver indítása
startServer();

export default app;
