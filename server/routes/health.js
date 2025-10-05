import express from 'express';
import { query } from '../config/database.js';

const router = express.Router();

// Health check endpoint
router.get('/health', async (req, res) => {
  try {
    // Ellenőrizzük az adatbázis kapcsolatot
    const result = await query('SELECT NOW() as time');

    res.status(200).json({
      status: 'OK',
      message: 'Server is running',
      timestamp: new Date().toISOString(),
      database: {
        connected: true,
        time: result.rows[0].time,
      },
      environment: process.env.NODE_ENV || 'development',
    });
  } catch (error) {
    res.status(503).json({
      status: 'ERROR',
      message: 'Database connection failed',
      timestamp: new Date().toISOString(),
      database: {
        connected: false,
        error: error.message,
      },
      environment: process.env.NODE_ENV || 'development',
    });
  }
});

// Aliveness probe (Kubernetes-ready)
router.get('/alive', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'Server is alive',
  });
});

// Readiness probe (Kubernetes-ready)
router.get('/ready', async (req, res) => {
  try {
    await query('SELECT 1');
    res.status(200).json({
      status: 'OK',
      message: 'Server is ready',
    });
  } catch (error) {
    res.status(503).json({
      status: 'ERROR',
      message: 'Server is not ready',
      error: error.message,
    });
  }
});

export default router;
