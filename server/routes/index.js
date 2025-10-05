import express from 'express';
import healthRouter from './health.js';

const router = express.Router();

// API verzió információ
router.get('/', (req, res) => {
  res.json({
    name: 'BarbiVue API',
    version: '1.0.0',
    description: 'Backend API for Busai Barbara Mediator website',
    endpoints: {
      health: '/api/health',
      alive: '/api/alive',
      ready: '/api/ready',
    },
  });
});

// Health check routes
router.use('/', healthRouter);

export default router;
