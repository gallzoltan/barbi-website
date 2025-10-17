### B. Database Schema Full SQL

Teljes adatbázis séma (copy-paste ready):

```sql
-- Full database schema for BarbiVue backend
-- Version: 1.0
-- Date: 2025-10-01

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set timezone
SET timezone = 'Europe/Budapest';

-- ========================================
-- TABLES
-- ========================================

-- Contact submissions
CREATE TABLE contact_submissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    message TEXT NOT NULL,
    subject VARCHAR(255),
    status VARCHAR(50) DEFAULT 'new', -- new, read, replied, spam
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Events
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    event_end_date DATE,
    location VARCHAR(255) NOT NULL,
    address TEXT,
    image_url VARCHAR(500),
    max_participants INTEGER,
    registration_deadline DATE,
    price DECIMAL(10, 2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'upcoming', -- upcoming, ongoing, completed, cancelled
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT valid_dates CHECK (event_end_date IS NULL OR event_end_date >= event_date),
    CONSTRAINT valid_registration_deadline CHECK (registration_deadline IS NULL OR registration_deadline <= event_date)
);

-- Event registrations
CREATE TABLE event_registrations (
    id SERIAL PRIMARY KEY,
    event_id INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    age INTEGER,
    dietary_restrictions TEXT,
    special_needs TEXT,
    accommodation_needed BOOLEAN DEFAULT false,
    status VARCHAR(50) DEFAULT 'pending', -- pending, confirmed, cancelled, attended
    payment_status VARCHAR(50) DEFAULT 'unpaid', -- unpaid, paid, refunded
    notes TEXT,
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT valid_phone CHECK (phone ~* '^(\+36|06)[0-9]{8,}$'),
    CONSTRAINT valid_age CHECK (age IS NULL OR (age >= 1 AND age <= 120))
);

-- Admin users
CREATE TABLE admin_users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'editor', -- admin, editor
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Content sections
CREATE TABLE content_sections (
    id SERIAL PRIMARY KEY,
    section_key VARCHAR(100) UNIQUE NOT NULL,
    content JSONB NOT NULL,
    version INTEGER DEFAULT 1,
    is_published BOOLEAN DEFAULT true,
    last_edited_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Content history
CREATE TABLE content_history (
    id SERIAL PRIMARY KEY,
    section_key VARCHAR(100) NOT NULL,
    content JSONB NOT NULL,
    version INTEGER NOT NULL,
    edited_by VARCHAR(255),
    edit_description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Newsletter subscribers
CREATE TABLE newsletter_subscribers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'active', -- active, unsubscribed, bounced
    subscription_source VARCHAR(100),
    verified BOOLEAN DEFAULT false,
    verification_token VARCHAR(255),
    unsubscribe_token VARCHAR(255) UNIQUE,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unsubscribed_at TIMESTAMP,

    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Testimonials
CREATE TABLE testimonials (
    id SERIAL PRIMARY KEY,
    author_name VARCHAR(255) NOT NULL,
    event_id INTEGER REFERENCES events(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    testimonial TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP
);

-- Analytics events
CREATE TABLE analytics_events (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB,
    page_path VARCHAR(500),
    session_id VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    referrer TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User consents (GDPR)
CREATE TABLE user_consents (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    consent_type VARCHAR(50) NOT NULL,
    consented BOOLEAN DEFAULT true,
    consent_text TEXT,
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- INDEXES
-- ========================================

-- Contact submissions
CREATE INDEX idx_contact_status ON contact_submissions(status);
CREATE INDEX idx_contact_created_at ON contact_submissions(created_at DESC);
CREATE INDEX idx_contact_email ON contact_submissions(email);

-- Events
CREATE INDEX idx_events_date ON events(event_date DESC);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_slug ON events(slug);

-- Event registrations
CREATE INDEX idx_registrations_event ON event_registrations(event_id);
CREATE INDEX idx_registrations_status ON event_registrations(status);
CREATE INDEX idx_registrations_email ON event_registrations(email);
CREATE UNIQUE INDEX idx_unique_registration ON event_registrations(event_id, email)
WHERE status != 'cancelled';

-- Content
CREATE INDEX idx_content_key ON content_sections(section_key);
CREATE INDEX idx_content_published ON content_sections(is_published);
CREATE INDEX idx_history_key ON content_history(section_key, version DESC);

-- Newsletter
CREATE INDEX idx_newsletter_status ON newsletter_subscribers(status);
CREATE INDEX idx_newsletter_email ON newsletter_subscribers(email);

-- Testimonials
CREATE INDEX idx_testimonials_approved ON testimonials(is_approved, created_at DESC);
CREATE INDEX idx_testimonials_featured ON testimonials(is_featured) WHERE is_featured = true;

-- Analytics
CREATE INDEX idx_analytics_type ON analytics_events(event_type, created_at DESC);
CREATE INDEX idx_analytics_session ON analytics_events(session_id);
CREATE INDEX idx_analytics_date ON analytics_events(DATE(created_at));

-- Consents
CREATE INDEX idx_consents_email ON user_consents(email);

-- ========================================
-- FUNCTIONS
-- ========================================

-- Check if event is full
CREATE OR REPLACE FUNCTION is_event_full(p_event_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    v_max_participants INTEGER;
    v_current_count INTEGER;
BEGIN
    SELECT max_participants INTO v_max_participants
    FROM events WHERE id = p_event_id;

    IF v_max_participants IS NULL THEN
        RETURN FALSE;
    END IF;

    SELECT COUNT(*) INTO v_current_count
    FROM event_registrations
    WHERE event_id = p_event_id
    AND status IN ('pending', 'confirmed');

    RETURN v_current_count >= v_max_participants;
END;
$$ LANGUAGE plpgsql;

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Save content history
CREATE OR REPLACE FUNCTION save_content_history()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO content_history (section_key, content, version, edited_by)
    VALUES (NEW.section_key, NEW.content, NEW.version, NEW.last_edited_by);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- TRIGGERS
-- ========================================

CREATE TRIGGER update_contact_updated_at BEFORE UPDATE ON contact_submissions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_registrations_updated_at BEFORE UPDATE ON event_registrations
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER save_content_history_trigger
AFTER UPDATE ON content_sections
FOR EACH ROW
WHEN (OLD.content IS DISTINCT FROM NEW.content)
EXECUTE FUNCTION save_content_history();

-- ========================================
-- MATERIALIZED VIEWS
-- ========================================

CREATE MATERIALIZED VIEW daily_analytics AS
SELECT
    DATE(created_at) as date,
    event_type,
    COUNT(*) as event_count,
    COUNT(DISTINCT session_id) as unique_sessions,
    COUNT(DISTINCT ip_address) as unique_visitors
FROM analytics_events
WHERE created_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE(created_at), event_type;

CREATE UNIQUE INDEX idx_daily_analytics ON daily_analytics(date, event_type);

-- ========================================
-- SEED DATA
-- ========================================

-- Insert initial events from database.json
INSERT INTO events (title, slug, description, event_date, location, image_url, status)
VALUES
  (
    'Krízis és kegyelem lelki hétvége',
    'krizis-es-kegyelem-2025-02',
    'Ez a program lehetőséget biztosít arra, hogy megértsük, hogyan működnek a traumák az életünkben...',
    '2025-02-07',
    'Pécs',
    '/assets/img/kriziseskegyelem.png',
    'upcoming'
  ),
  (
    'Boldogok a békességszerzők',
    'boldogok-a-bekessegszerzok-2025-03',
    'A Jézusi konfliktusmegoldás a béke és a bűnbocsánat evangéliumára épül...',
    '2025-03-14',
    'Budapest, Krisztus Király Missziós Központ',
    '/assets/img/bekessegszerzok.png',
    'upcoming'
  ),
  (
    'Konfliktuskezelő műhely',
    'konfliktuskezelo-muhely-2025-06',
    'A békés konfliktuskezelés módszerei a mindennapokban.',
    '2025-06-20',
    'Online (Zoom)',
    '/assets/img/konfliktus.png',
    'upcoming'
  );

-- Insert content sections from database.json
INSERT INTO content_sections (section_key, content) VALUES
('hero', '{"title": "A bizalom csodákat tesz.", "subtitle": "Szeretettel köszöntöm..."}'),
('about', '{"title": "Tanulmányaim", "sections": []}'),
('services', '[]'),
('princesses', '{"id": 1, "title": "Áldott királylányok"}'),
('contact', '{"p1": "Ha kérdése van...", "email": "info@busaibarbara.hu"}'),
('footer', '{"copyright": "© 2025 Gállné Busai Barbara"}');

-- ========================================
-- PERMISSIONS (Create limited user)
-- ========================================

-- CREATE USER barbivue_app WITH PASSWORD 'change-this-password';
-- GRANT CONNECT ON DATABASE barbivue_db TO barbivue_app;
-- GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO barbivue_app;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO barbivue_app;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO barbivue_app;
```
-- End of database schema