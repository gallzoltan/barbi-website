import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const { Pool } = pg;

// Database pool létrehozása
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  database: process.env.DB_NAME || 'barbi_db',
  user: process.env.DB_USER || 'barbivue',
  password: process.env.DB_PASSWORD || 'admin',
});

// Migrations tábla létrehozása, ha nem létezik
async function createMigrationsTable() {
  const query = `
    CREATE TABLE IF NOT EXISTS migrations (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL UNIQUE,
      executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;
  await pool.query(query);
  console.log('✓ Migrations table ready');
}

// Végrehajtott migrációk lekérése
async function getExecutedMigrations() {
  const result = await pool.query('SELECT name FROM migrations ORDER BY id');
  return result.rows.map(row => row.name);
}

// Migration fájlok beolvasása
async function getMigrationFiles() {
  const files = await fs.readdir(__dirname);
  return files
    .filter(file => file.endsWith('.sql'))
    .sort();
}

// Migration végrehajtása
async function executeMigration(filename, direction = 'up') {
  const filePath = path.join(__dirname, filename);
  const content = await fs.readFile(filePath, 'utf-8');

  // SQL fájl szétválasztása UP és DOWN részekre
  const parts = content.split('-- DOWN');
  const upSQL = parts[0].replace('-- UP', '').trim();
  const downSQL = parts[1] ? parts[1].trim() : '';

  const sql = direction === 'up' ? upSQL : downSQL;

  if (!sql) {
    throw new Error(`No ${direction.toUpperCase()} section found in ${filename}`);
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(sql);

    if (direction === 'up') {
      await client.query('INSERT INTO migrations (name) VALUES ($1)', [filename]);
      console.log(`  ✓ Applied: ${filename}`);
    } else {
      await client.query('DELETE FROM migrations WHERE name = $1', [filename]);
      console.log(`  ✓ Reverted: ${filename}`);
    }

    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Migrációk futtatása (UP)
async function runMigrationsUp() {
  console.log('Running migrations UP...\n');

  await createMigrationsTable();
  const executed = await getExecutedMigrations();
  const allMigrations = await getMigrationFiles();

  const pending = allMigrations.filter(file => !executed.includes(file));

  if (pending.length === 0) {
    console.log('✓ No pending migrations');
    return;
  }

  console.log(`Found ${pending.length} pending migration(s):\n`);

  for (const file of pending) {
    await executeMigration(file, 'up');
  }

  console.log('\n✓ All migrations completed successfully');
}

// Migrációk visszavonása (DOWN)
async function runMigrationsDown(steps = 1) {
  console.log(`Rolling back ${steps} migration(s)...\n`);

  await createMigrationsTable();
  const executed = await getExecutedMigrations();

  if (executed.length === 0) {
    console.log('✓ No migrations to roll back');
    return;
  }

  const toRevert = executed.slice(-steps).reverse();

  console.log(`Rolling back ${toRevert.length} migration(s):\n`);

  for (const file of toRevert) {
    await executeMigration(file, 'down');
  }

  console.log('\n✓ Rollback completed successfully');
}

// Új migration fájl létrehozása
async function createMigration(name) {
  if (!name) {
    console.error('❌ Please provide a migration name');
    console.log('Usage: npm run migrate:create <migration_name>');
    return;
  }

  const timestamp = new Date().toISOString().replace(/[-:]/g, '').split('.')[0];
  const filename = `${timestamp}_${name}.sql`;
  const filePath = path.join(__dirname, filename);

  const template = `-- UP
-- Write your migration SQL here
CREATE TABLE IF NOT EXISTS example (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- DOWN
-- Write your rollback SQL here
DROP TABLE IF EXISTS example;
`;

  await fs.writeFile(filePath, template);
  console.log(`✓ Created migration: ${filename}`);
}

// Migration lista megjelenítése
async function listMigrations() {
  await createMigrationsTable();
  const executed = await getExecutedMigrations();
  const allMigrations = await getMigrationFiles();

  console.log('\nMigration Status:\n');
  console.log('='.repeat(60));

  for (const file of allMigrations) {
    const status = executed.includes(file) ? '✓ Applied' : '○ Pending';
    console.log(`${status}  ${file}`);
  }

  console.log('='.repeat(60));
  console.log(`\nTotal: ${allMigrations.length} | Applied: ${executed.length} | Pending: ${allMigrations.length - executed.length}\n`);
}

// Main futtatás
async function main() {
  const command = process.argv[2];
  const arg = process.argv[3];

  try {
    switch (command) {
      case 'up':
        await runMigrationsUp();
        break;
      case 'down':
        await runMigrationsDown(parseInt(arg || '1', 10));
        break;
      case 'create':
        await createMigration(arg);
        break;
      case 'list':
        await listMigrations();
        break;
      default:
        console.log('Usage:');
        console.log('  npm run migrate:up           - Run all pending migrations');
        console.log('  npm run migrate:down [n]     - Rollback last n migrations (default: 1)');
        console.log('  npm run migrate:create <name> - Create new migration file');
        console.log('  npm run migrate:list         - List all migrations with status');
    }
  } catch (error) {
    console.error('❌ Migration error:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

main();
