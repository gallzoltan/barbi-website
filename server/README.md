# BarbiVue Backend Server

Express.js alapú backend API a Busai Barbara Mediátor weboldalhoz PostgreSQL adatbázissal.

## Technológiai Stack

- **Node.js** (ES Modules)
- **Express.js** v5.x - Web framework
- **PostgreSQL** - Adatbázis
- **pg** - PostgreSQL kliens connection pooling-gal
- **CORS** - Cross-Origin Resource Sharing
- **Helmet** - Biztonsági HTTP headerek
- **Express Rate Limit** - Rate limiting és spam védelem
- **dotenv** - Environment változók kezelése

## Projekt Struktúra

```
server/
├── config/
│   └── database.js          # PostgreSQL kapcsolat és pool konfiguráció
├── middleware/
│   ├── cors.js              # CORS middleware konfiguráció
│   ├── security.js          # Helmet biztonsági beállítások
│   ├── rateLimiter.js       # Rate limiting middleware-ek
│   ├── errorHandler.js      # Globális hibakezelő
│   └── logger.js            # Request logger
├── routes/
│   ├── index.js             # Fő route handler
│   └── health.js            # Health check endpointok
├── migrations/
│   ├── migrate.js           # Migration runner
│   └── *.sql                # SQL migration fájlok
├── controllers/             # Business logic (későbbi használatra)
├── models/                  # Adatbázis modellek (későbbi használatra)
├── services/                # Szolgáltatások (későbbi használatra)
├── utils/                   # Segédfunkciók (későbbi használatra)
├── .env                     # Environment változók (NEM verziókövetett)
├── .env.example             # Environment változók példa
├── package.json             # Függőségek és scriptek
└── server.js                # Fő szerver fájl
```

## Telepítés és Indítás

### 1. Függőségek telepítése

```bash
cd server
npm install
```

### 2. Environment változók beállítása

Másold le az `.env.example` fájlt `.env` névre és állítsd be az értékeket:

```bash
cp .env.example .env
```

Szerkeszd a `.env` fájlt a megfelelő értékekkel:
- `DB_PASSWORD=admin` (alapértelmezett a fejlesztéshez)
- További beállítások igény szerint

### 3. PostgreSQL adatbázis létrehozása

```bash
# PostgreSQL-be való bejelentkezés
psql -U postgres

# Adatbázis létrehozása
CREATE USER barbivue LOGIN CREATEDB PASSWORD 'admin';
CREATE DATABASE barbi_db OWNER barbivue;

# Kilépés
\q
```

### 4. Adatbázis migrációk futtatása

```bash
npm run migrate:up
```

### 5. Szerver indítása

Fejlesztési mód (auto-reload):
```bash
npm run dev
```

Production mód:
```bash
npm start
```

A szerver elindul: `http://localhost:3000`

## API Endpointok

### Általános

- `GET /` - API információk
- `GET /api` - API verzió és elérhető endpointok

### Health Check

- `GET /api/health` - Részletes health check (adatbázis kapcsolat is)
- `GET /api/alive` - Aliveness probe (Kubernetes-ready)
- `GET /api/ready` - Readiness probe (Kubernetes-ready)

## Database Migrációk

### Migration parancsok

```bash
# Összes pending migration futtatása
npm run migrate:up

# Utolsó migration visszavonása
npm run migrate:down

# Utolsó n migration visszavonása
npm run migrate:down 3

# Új migration létrehozása
npm run migrate:create <migration_name>

# Migration-ök listázása (státusz)
npm run migrate:list
```

### Migration fájl struktúra

A migration fájlok `.sql` formátumúak és két részből állnak:

```sql
-- UP
-- Ide jön az adatbázis változtatás SQL kódja
CREATE TABLE example (...);

-- DOWN
-- Ide jön a rollback SQL kód
DROP TABLE example;
```

Fájlnév formátum: `YYYYMMDDHHMMSS_migration_name.sql`

## Environment Változók

### Szerver

- `NODE_ENV` - Környezet (development/production)
- `PORT` - Szerver port (default: 3000)
- `HOST` - Szerver host (default: localhost)

### Adatbázis

- `DB_HOST` - PostgreSQL host (default: localhost)
- `DB_PORT` - PostgreSQL port (default: 5432)
- `DB_NAME` - Adatbázis név (default: barbivue)
- `DB_USER` - Adatbázis felhasználó (default: postgres)
- `DB_PASSWORD` - Adatbázis jelszó (default: admin)
- `DB_MAX_CONNECTIONS` - Maximum kapcsolatok (default: 20)
- `DB_IDLE_TIMEOUT` - Idle timeout ms (default: 30000)
- `DB_CONNECTION_TIMEOUT` - Connection timeout ms (default: 2000)

### CORS

- `CORS_ORIGIN` - Engedélyezett origin-ek (default: http://localhost:5173)
- `CORS_CREDENTIALS` - Credentials engedélyezése (default: true)

### Rate Limiting

- `RATE_LIMIT_WINDOW_MS` - Rate limit időablak ms (default: 3600000 = 1 óra)
- `RATE_LIMIT_MAX_REQUESTS` - Maximum kérések száma (default: 100)

### Logging

- `LOG_LEVEL` - Log szint (debug/info/warn/error)
- `LOG_FORMAT` - Log formátum (dev/combined)

## Biztonsági Funkciók

### Helmet (HTTP Security Headers)

- Content Security Policy
- DNS Prefetch Control
- Frameguard (clickjacking védelem)
- HSTS (HTTP Strict Transport Security)
- MIME Type Sniffing védelem
- Referrer Policy
- XSS Filter

### Rate Limiting

- **generalLimiter**: 100 kérés / óra (alapértelmezett API végpontokra)
- **strictLimiter**: 5 kérés / 15 perc (pl. login, regisztráció)
- **emailLimiter**: 3 email / óra (spam védelem)

### CORS

- Konfigurálható origin whitelist
- Credentials támogatás
- Preflight cache

### Database

- Connection pooling
- Parameterized queries (SQL injection védelem)
- Transaction támogatás
- Graceful shutdown

## Hibakezelés

A backend központosított hibakezelést használ:

- **404 Not Found** - Nem létező endpointokra
- **Database hibák** - Automatikus constraint violation kezelés
- **Validation hibák** - Részletes hibaüzenetek
- **JWT hibák** - Authentikáció hibák
- **CORS hibák** - Origin policy megsértés
- **Global error handler** - Minden kezeletlen hiba

## Logging

A request logger minden kérést naplóz:
- Timestamp
- HTTP method
- Path
- Status code
- Response time
- Client IP

Színkódolt output a fejlesztési környezetben.

## Graceful Shutdown

A szerver gracefully kezel shutdown jeleket:
- `SIGTERM` - Normális leállítás
- `SIGINT` - Ctrl+C
- Database pool lezárása
- Folyamatban lévő kérések befejezése

## Development

### Nodemon

A `npm run dev` parancs nodemon-t használ, amely automatikusan újraindítja a szervert fájlváltozás esetén.

Figyelt fájlok: `.js`, `.json`, `.env`

### Debug Mode

Debug információkhoz állítsd be:
```env
LOG_LEVEL=debug
NODE_ENV=development
```

Ez részletes SQL query logokat és request információkat ad.

## Production Checklist

- [ ] `NODE_ENV=production` beállítása
- [ ] Erős `DB_PASSWORD` generálása
- [ ] `SESSION_SECRET` és `JWT_SECRET` random stringek generálása
- [ ] `CORS_ORIGIN` korlátozása production domain-re
- [ ] Rate limiting értékek finomhangolása
- [ ] SSL/TLS konfiguráció (HTTPS)
- [ ] Database backup stratégia
- [ ] Monitoring és logging rendszer
- [ ] Health check endpointok tesztelése
- [ ] Environment változók titkosított tárolása

## Következő Lépések (PRD Week 3-4)

- Contact form endpoint implementálása
- Email service setup (SendGrid/Nodemailer)
- Input validation (express-validator)
- Contact submissions tábla létrehozása

## License

ISC
