import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

// PostgreSQL kapcsolat konfiguráció
const poolConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  database: process.env.DB_NAME || 'barbivue',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'admin',
  max: parseInt(process.env.DB_MAX_CONNECTIONS || '20', 10),
  idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT || '30000', 10),
  connectionTimeoutMillis: parseInt(process.env.DB_CONNECTION_TIMEOUT || '2000', 10),
};

// Connection pool létrehozása
const pool = new Pool(poolConfig);

// Pool event handlers a megfelelő monitorozáshoz és hibakezeléshez
pool.on('connect', () => {
  console.log('✓ Database connection established');
});

pool.on('error', (err) => {
  console.error('❌ Unexpected database error:', err);
  process.exit(-1);
});

pool.on('remove', () => {
  console.log('Database client removed from pool');
});

// Adatbázis kapcsolat tesztelése
export async function testConnection() {
  let client;
  try {
    client = await pool.connect();
    const result = await client.query('SELECT NOW() as now, version() as version');
    console.log('✓ Database connection successful');
    console.log(`  Time: ${result.rows[0].now}`);
    console.log(`  PostgreSQL version: ${result.rows[0].version.split(',')[0]}`);
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    throw error;
  } finally {
    if (client) {
      client.release();
    }
  }
}

// Pool lezárása graceful shutdown esetén
export async function closePool() {
  try {
    await pool.end();
    console.log('✓ Database pool closed');
  } catch (error) {
    console.error('❌ Error closing database pool:', error);
    throw error;
  }
}

// Query wrapper hibakezeléssel
export async function query(text, params) {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;

    if (process.env.NODE_ENV === 'development' && process.env.LOG_LEVEL === 'debug') {
      console.log('Query executed:', { text, duration: `${duration}ms`, rows: result.rowCount });
    }

    return result;
  } catch (error) {
    console.error('Query error:', { text, error: error.message });
    throw error;
  }
}

// Transaction wrapper
export async function withTransaction(callback) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Pool export a közvetlen használathoz szükség esetén
export { pool };

export default {
  query,
  pool,
  testConnection,
  closePool,
  withTransaction,
};
