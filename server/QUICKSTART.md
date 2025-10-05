# BarbiVue Backend - Gyors Indítás

## Opció 1: Docker használatával (Ajánlott kezdőknek)

### Előfeltételek
- Docker és Docker Compose telepítve

### Lépések

1. **PostgreSQL indítása Docker-ben:**
   ```bash
   cd server
   docker-compose up -d
   ```

   Ez elindít egy PostgreSQL konténert:
   - Database: `barbi_db`
   - User: `barbivue`
   - Password: `admin`
   - Port: `5432`

2. **Függőségek telepítése:**
   ```bash
   npm install
   ```

3. **Environment változók beállítása:**
   ```bash
   cp .env.example .env
   ```

   Az `.env` fájl már tartalmazza a megfelelő beállításokat a Docker PostgreSQL-hez.

4. **Database migrációk futtatása:**
   ```bash
   npm run migrate:up
   ```

5. **Szerver indítása:**
   ```bash
   npm run dev
   ```

6. **Tesztelés:**
   Nyisd meg böngészőben: `http://localhost:3000/api/health`

### Docker leállítása

```bash
docker-compose down          # PostgreSQL leállítása
docker-compose down -v       # PostgreSQL leállítása és adatok törlése
```

### pgAdmin használata (opcionális)

Ha szeretnéd grafikusan kezelni az adatbázist:

```bash
docker-compose --profile tools up -d
```

Megnyitás: `http://localhost:5050`
- Email: `admin@barbivue.local`
- Password: `admin`

Server kapcsolat hozzáadása:
- Host: `postgres` (vagy `host.docker.internal` Mac/Windows-on)
- Port: `5432`
- Database: `barbivue`
- Username: `postgres`
- Password: `admin`

---

## Opció 2: Natív PostgreSQL telepítéssel

### Előfeltételek
- PostgreSQL 12+ telepítve és fut
- Node.js 18+ telepítve

### Lépések

1. **Automatikus setup (Linux/macOS):**
   ```bash
   cd server
   ./setup.sh
   ```

   Ez a script:
   - Ellenőrzi a PostgreSQL telepítést
   - Létrehozza az adatbázist
   - Telepíti a függőségeket
   - Futtatja a migrációkat

2. **Manuális setup:**

   a) **PostgreSQL adatbázis létrehozása:**
   ```bash
   sudo -u postgres psql
   ```
   ```sql
   CREATE USER barbivue LOGIN CREATEDB PASSWORD 'admin';
   CREATE DATABASE barbi_db OWNER barbivue;
   \q
   ```

   b) **Environment változók:**
   ```bash
   cp .env.example .env
   ```

   Szerkeszd az `.env` fájlt szükség esetén (jelszó, stb.)

   c) **Függőségek telepítése:**
   ```bash
   npm install
   ```

   d) **Migrációk futtatása:**
   ```bash
   npm run migrate:up
   ```

   e) **Szerver indítása:**
   ```bash
   npm run dev
   ```

---

## Gyakori Parancsok

### Development

```bash
npm run dev              # Szerver indítása dev módban (auto-reload)
npm start                # Szerver indítása production módban
```

### Database Migrációk

```bash
npm run migrate:up       # Összes pending migration futtatása
npm run migrate:down     # Utolsó migration visszavonása
npm run migrate:list     # Migration-ök listázása státusszal
npm run migrate:create my_migration  # Új migration létrehozása
```

### Tesztelés

```bash
# Health check
curl http://localhost:3000/api/health

# API info
curl http://localhost:3000/api
```

---

## Környezeti Változók (Gyors Referencia)

```env
# Szerver
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=barbi_db
DB_USER=barbivue
DB_PASSWORD=admin        # Változtasd meg production-ben!

# CORS
CORS_ORIGIN=http://localhost:5173

# Logging
LOG_LEVEL=debug
```

---

## Hibaelhárítás

### "Database connection failed"

1. Ellenőrizd, hogy PostgreSQL fut:
   ```bash
   # Docker
   docker-compose ps

   # Natív
   sudo systemctl status postgresql
   ```

2. Ellenőrizd a kapcsolódási paramétereket az `.env` fájlban

3. Teszteld a kapcsolatot:
   ```bash
   psql -h localhost -U postgres -d barbivue
   ```

### "Port 3000 is already in use"

Változtasd meg a portot az `.env` fájlban:
```env
PORT=3001
```

### "Cannot find module"

```bash
npm install
```

### "Migration already exists"

Ellenőrizd a migration státuszt:
```bash
npm run migrate:list
```

Ha szükséges, vonj vissza migration-öket:
```bash
npm run migrate:down
```

---

## Következő Lépések

1. ✅ Backend sikeresen fut
2. 📝 Ismerkedj meg az API-val: `/server/README.md`
3. 🔨 Következő fase implementálása (PRD Week 3-4): Contact form
4. 🧪 API tesztelés Postman-nel vagy curl-lel

---

## Hasznos Linkek

- **API dokumentáció**: `/server/README.md`
- **PRD**: `/docs/PRD.md`
- **Health check**: http://localhost:3000/api/health
- **pgAdmin** (Docker): http://localhost:5050

---

Ha bármilyen problémád van, ellenőrizd a részletes dokumentációt a `README.md` fájlban!
