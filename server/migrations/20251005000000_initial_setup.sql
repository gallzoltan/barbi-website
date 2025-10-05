-- UP
-- Initial database setup
-- Létrehozza az alapvető database struktúrát és extension-öket

-- UUID támogatás (hasznos lehet későbbi felhasználásokhoz)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Timestamp tracking function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Log táblázat rendszer eseményekhez
CREATE TABLE IF NOT EXISTS system_logs (
  id SERIAL PRIMARY KEY,
  level VARCHAR(20) NOT NULL DEFAULT 'info',
  message TEXT NOT NULL,
  context JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index a gyorsabb kereséshez
CREATE INDEX IF NOT EXISTS idx_system_logs_level ON system_logs(level);
CREATE INDEX IF NOT EXISTS idx_system_logs_created_at ON system_logs(created_at DESC);

-- DOWN
-- Rollback: töröljük az initial setup által létrehozott objektumokat

DROP INDEX IF EXISTS idx_system_logs_created_at;
DROP INDEX IF EXISTS idx_system_logs_level;
DROP TABLE IF EXISTS system_logs;
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP EXTENSION IF EXISTS "uuid-ossp";
