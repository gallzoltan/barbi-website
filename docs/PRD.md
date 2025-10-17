# Product Requirements Document (PRD)
# Backend Fejlesztési Terv - BarbiVue Projekt

**Verzió:** 1.0
**Dátum:** 2025-10-01
**Projekt:** Gállné Busai Barbara Mediátor Weboldal Backend
**Típus:** Mediálás, események, programok

---

## 1. Executive Summary

### 1.1 Jelenlegi Helyzet
A BarbiVue projekt jelenleg egy tisztán frontend Vue.js alkalmazás, amely statikus JSON fájlból (`/public/database.json`) tölti be az összes tartalmat. Nincs backend infrastruktúra, adatbázis kapcsolat, vagy szerver oldali logika.

### 1.2 Probléma
- **Nincs működő kapcsolatfelvételi űrlap** - csak statikus elérhetőségek
- **Külső függőség eseményregisztrációhoz** - Google Forms használata
- **Tartalom frissítése nehézkes** - minden változtatás újratelepítést igényel
- **Nincs adatkezelés** - nincs CRM, jelentkezők nyilvántartása
- **Skálázhatósági problémák** - statikus megoldás nem bővíthető

### 1.3 Célok
Backend infrastruktúra kiépítése, amely lehetővé teszi:
1. Közvetlen kapcsolatfelvételt a weboldalon keresztül
2. Eseményregisztrációk kezelése saját rendszerben
3. Tartalom dinamikus szerkesztése admin felületen
4. Adatok központi tárolása és kezelése
5. Automatizált email kommunikáció

### 1.4 Siker Metrikák
- **Kapcsolatfelvételi űrlap aktiválás:** 90%+ email kézbesítési arány
- **Eseményregisztrációk:** 100% áttérés Google Forms-ról saját rendszerre
- **Rendszer uptime:** 99.5%+
- **Válaszidő:** <500ms átlagos API response time

---

## 2. Fázisok és Prioritások

### 2.1 Prioritási Mátrix

| Funkció | Prioritás | Hatás | Erőfeszítés | ROI | Timeline |
|---------|-----------|-------|-------------|-----|----------|
| Kapcsolatfelvételi űrlap | **HIGH** | Magas | Alacsony | Kiváló | 1-2 hét |
| Eseményregisztrációs rendszer | **HIGH** | Nagyon Magas | Közepes | Kiváló | 2-4 hét |
| Email értesítési rendszer | **HIGH** | Magas | Alacsony | Kiváló | 1 hét |
| Content Management System | **MEDIUM** | Magas | Közepes | Jó | 3-4 hét |
| Admin Dashboard | **MEDIUM** | Közepes | Magas | Jó | 4-6 hét |
| Hírlevél feliratkozás | **LOW** | Közepes | Alacsony | Jó | 1-2 hét |
| Vélemények/visszajelzések | **LOW** | Közepes | Alacsony | Jó | 1-2 hét |
| Analitika | **MEDIUM** | Közepes | Közepes | Jó | 2-3 hét |
| Fizetési integráció | **LOW** | Magas | Magas | Függ | 3-5 hét |
| Felhasználói autentikáció | **LOW** | Alacsony | Közepes | Alacsony | 2-3 hét |

---

## 3. PHASE 1: Alapvető Backend Funkciók (HIGH Priority)

### 3.1 Kapcsolatfelvételi Űrlap API

#### 3.1.1 Üzleti Követelmények
- Weboldalon kitölthető kapcsolatfelvételi űrlap
- Automatikus email értesítés adminisztrátornak
- Automatikus visszaigazoló email a küldőnek
- Spam védelem
- Üzenetek archiválása

#### 3.1.2 Funkcionális Követelmények

**Felhasználói Story:**
> "Látogatóként szeretnék üzenetet küldeni Barbarának anélkül, hogy email klienst kellene használnom vagy telefonálnom kellene."

**API Endpoint:**
```
POST /api/contact
Request Body: {
  name: string (required, 2-255 karakter),
  email: string (required, valid email),
  phone: string (optional, magyar formátum),
  message: string (required, 10-2000 karakter),
  subject: string (optional, max 255 karakter)
}

Response: {
  success: boolean,
  message: string,
  submission_id: number (optional)
}
```

**Validációs Szabályok:**
- `name`: minimum 2 karakter, maximum 255
- `email`: valid email formátum, normalizálva (kisbetűsítés)
- `phone`: opcionális, magyar telefon formátum (+36 vagy 06)
- `message`: minimum 10 karakter, maximum 2000, XSS védelem
- `subject`: opcionális, maximum 255 karakter

**Rate Limiting:**
- 3 üzenet / óra / IP cím
- 429 Too Many Requests válasz túllépés esetén

**Email Értesítések:**

*Admin értesítés:*
```
To: info@busaibarbara.hu (process.env.ADMIN_EMAIL)
Subject: Új kapcsolatfelvételi üzenet: [subject]
Body:
  Új üzenet érkezett a weboldalról

  Név: [name]
  Email: [email]
  Telefon: [phone vagy "Nem adta meg"]

  Üzenet:
  [message]

  IP cím: [ip_address]
  Időpont: [timestamp]
```

*Visszaigazoló email:*
```
To: [user_email]
Subject: Köszönjük megkeresését
Body:
  Kedves [name]!

  Köszönjük, hogy felvette velünk a kapcsolatot.
  Üzenetét megkaptuk és hamarosan válaszolunk.

  Üdvözlettel,
  Gállné Busai Barbara

  ---
  Ez egy automatikus üzenet, kérjük ne válaszoljon rá.
```

#### 3.1.3 Adatbázis Séma

```sql
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

CREATE INDEX idx_contact_status ON contact_submissions(status);
CREATE INDEX idx_contact_created_at ON contact_submissions(created_at DESC);
CREATE INDEX idx_contact_email ON contact_submissions(email);
```

#### 3.1.4 Biztonsági Követelmények
- SQL injection védelem: parameterized queries
- XSS védelem: input sanitization (sanitize-html)
- CSRF védelem: CSRF tokenek
- Rate limiting: 3 req/hour/IP
- Email validation: regex + DNS check
- Honeypot mező spam botok ellen
- IP cím és User-Agent naplózás

#### 3.1.5 Frontend Integráció
```vue
<!-- src/components/ContactForm.vue -->
<template>
  <form @submit.prevent="submitContact">
    <input v-model="form.name" required />
    <input v-model="form.email" type="email" required />
    <input v-model="form.phone" />
    <textarea v-model="form.message" required></textarea>
    <button type="submit" :disabled="loading">Küldés</button>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">Üzenet elküldve!</div>
  </form>
</template>

<script setup>
const submitContact = async () => {
  try {
    const response = await fetch('/api/contact', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form)
    });
    // Handle response
  } catch (error) {
    // Handle error
  }
};
</script>
```

---

### 3.2 Eseményregisztrációs Rendszer

#### 3.2.1 Üzleti Követelmények
- Google Forms helyettesítése saját rendszerrel
- Események listázása és részletes információk megjelenítése
- Online regisztráció események
- Automatikus megerősítő emailek
- Létszámkorlát kezelése
- Jelentkezési határidők kezelése
- Admin felület a jelentkezők megtekintésére

#### 3.2.2 Funkcionális Követelmények

**Felhasználói Story #1:**
> "Látogatóként szeretnének regisztrálni egy kurzusra anélkül, hogy Google Form-ot kellene kitöltenem."

**Felhasználói Story #2:**
> "Adminként szeretném látni az összes jelentkezőt egy eseményre, email címüket, telefonszámukat és különleges igényeiket."

**API Endpoints:**

```
GET /api/events
Response: [{
  id, title, slug, description, event_date, event_end_date,
  location, address, image_url, max_participants,
  registration_deadline, price, status,
  registered_count, is_full
}]

GET /api/events/:slug
Response: { ... event details ... }

POST /api/events/:slug/register
Request Body: {
  full_name: string (required, 3-255 karakter),
  email: string (required, valid email),
  phone: string (required, magyar formátum),
  age: number (optional, 1-120),
  dietary_restrictions: string (optional, max 500 karakter),
  special_needs: string (optional, max 1000 karakter),
  accommodation_needed: boolean (optional, default false)
}

Response: {
  success: boolean,
  message: string,
  registration_id: number
}

GET /api/admin/events/:eventId/registrations (AUTH required)
Response: [{ ... all registrations ... }]
```

**Validációs Szabályok:**
- `full_name`: minimum 3 karakter, maximum 255
- `email`: valid email, unique per event
- `phone`: kötelező, magyar telefonszám formátum
- `age`: opcionális, 1-120 közötti szám
- `dietary_restrictions`: max 500 karakter
- `special_needs`: max 1000 karakter

**Üzleti Logika:**
1. **Ellenőrzések regisztráció előtt:**
   - Esemény létezik-e?
   - Esemény státusza 'upcoming'?
   - Jelentkezési határidő nem járt le?
   - Van még hely? (nem telített)
   - Nem regisztrált már ezzel az email címmel?

2. **Sikeres regisztráció után:**
   - Adatbázisba mentés
   - Megerősítő email küldése a jelentkezőnek
   - Értesítő email küldése az adminnak

3. **Email értesítések:**

*Megerősítő email jelentkezőnek:*
```
To: [user_email]
Subject: Sikeres regisztráció - [event_title]
Body:
  Kedves [full_name]!

  Sikeresen regisztrált a következő programunkra:

  📅 Program: [event_title]
  📍 Helyszín: [location]
  🗓️ Időpont: [event_date]

  Regisztrációs azonosító: #[registration_id]

  Hamarosan további információkat küldünk a programmal kapcsolatban.

  Ha kérdése van, lépjen kapcsolatba velünk:
  📧 [admin_email]
  📱 [admin_phone]

  Üdvözlettel,
  Gállné Busai Barbara
```

*Értesítő email adminnak:*
```
To: [admin_email]
Subject: Új jelentkezés - [event_title]
Body:
  Új jelentkezés érkezett!

  Program: [event_title]
  Időpont: [event_date]

  JELENTKEZŐ ADATAI:
  Név: [full_name]
  Email: [email]
  Telefon: [phone]
  Életkor: [age vagy "nem adta meg"]

  Étkezési korlátozások: [dietary_restrictions vagy "nincs"]
  Különleges igények: [special_needs vagy "nincs"]
  Szállás szükséges: [accommodation_needed ? "Igen" : "Nem"]

  Jelenlegi létszám: [current_count] / [max_participants]

  Regisztráció részletei:
  [admin_panel_url]/registrations/[registration_id]
```

#### 3.2.3 Adatbázis Séma

```sql
-- Események táblája
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

-- Esemény regisztrációk táblája
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
    notes TEXT, -- Admin notes
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT valid_phone CHECK (phone ~* '^(\+36|06)[0-9]{8,}$'),
    CONSTRAINT valid_age CHECK (age IS NULL OR (age >= 1 AND age <= 120))
);

-- Egyedi constraint: egy email cím csak egyszer regisztrálhat egy eseményre (kivéve lemondott)
CREATE UNIQUE INDEX idx_unique_registration
ON event_registrations(event_id, email)
WHERE status != 'cancelled';

-- Indexek a gyorsabb lekérdezésekhez
CREATE INDEX idx_events_date ON events(event_date DESC);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_slug ON events(slug);
CREATE INDEX idx_registrations_event ON event_registrations(event_id);
CREATE INDEX idx_registrations_status ON event_registrations(status);
CREATE INDEX idx_registrations_email ON event_registrations(email);

-- Függvény: esemény betelt-e?
CREATE OR REPLACE FUNCTION is_event_full(p_event_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    v_max_participants INTEGER;
    v_current_count INTEGER;
BEGIN
    SELECT max_participants INTO v_max_participants
    FROM events WHERE id = p_event_id;

    -- Ha nincs létszámkorlát
    IF v_max_participants IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Aktív regisztrációk száma
    SELECT COUNT(*) INTO v_current_count
    FROM event_registrations
    WHERE event_id = p_event_id
    AND status IN ('pending', 'confirmed');

    RETURN v_current_count >= v_max_participants;
END;
$$ LANGUAGE plpgsql;

-- Trigger: updated_at frissítése
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_registrations_updated_at BEFORE UPDATE ON event_registrations
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

#### 3.2.4 Adatmigráció a Jelenlegi JSON-ből

A `/public/database.json` fájl jelenleg tartalmazza a "currents" (aktuális programok) szakaszt. Ez át kell vezetni az `events` táblába.

```sql
-- Seed data: meglévő események migrálása
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
```

#### 3.2.5 Frontend Integráció

**Események listázása:**
```vue
<!-- src/components/EventsList.vue -->
<script setup>
import { ref, onMounted } from 'vue';

const events = ref([]);
const loading = ref(true);

onMounted(async () => {
  const response = await fetch('/api/events');
  events.value = await response.json();
  loading.value = false;
});
</script>

<template>
  <div v-if="loading">Betöltés...</div>
  <div v-else>
    <div v-for="event in events" :key="event.id" class="event-card">
      <img :src="event.image_url" :alt="event.title" />
      <h3>{{ event.title }}</h3>
      <p>{{ event.event_date }} - {{ event.location }}</p>
      <router-link :to="`/events/${event.slug}`">
        Részletek és jelentkezés
      </router-link>
      <span v-if="event.is_full" class="badge">BETELT</span>
    </div>
  </div>
</template>
```

**Regisztrációs űrlap:**
```vue
<!-- src/components/EventRegistrationForm.vue -->
<script setup>
import { ref } from 'vue';

const props = defineProps(['eventSlug']);
const form = ref({
  full_name: '',
  email: '',
  phone: '',
  age: null,
  dietary_restrictions: '',
  special_needs: '',
  accommodation_needed: false
});

const submitRegistration = async () => {
  const response = await fetch(`/api/events/${props.eventSlug}/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(form.value)
  });

  if (response.ok) {
    // Sikeres regisztráció
    alert('Sikeres regisztráció! Megerősítő emailt küldtünk.');
  } else {
    // Hiba kezelése
    const error = await response.json();
    alert(error.message);
  }
};
</script>
```

---

### 3.3 Email Értesítési Rendszer

#### 3.3.1 Technikai Követelmények

**Email Service Provider Választás:**

| Szolgáltató | Ingyenes Limit | Ár | Ajánlás |
|------------|----------------|-----|---------|
| **SendGrid** | 100 email/nap | $15/hó (40k email) | ✅ Ajánlott kezdéshez |
| **Mailgun** | 5000 email/hó | $35/hó (50k email) | ✅ Jó alternatíva |
| **AWS SES** | 62000 email/hó | $0.10/1000 email | ⚠️ Bonyolultabb setup |
| **Gmail SMTP** | 500 email/nap | Ingyenes | ⚠️ Csak fejlesztéshez |
| **Microware** | 100 email/nap | Benne van a hosting árban | self hosting |

**Javasolt megoldás:** Microware

#### 3.3.2 Email Sablonok (Templates)

**1. Kapcsolatfelvételi visszaigazolás**
```html
<!-- templates/contact-confirmation.html -->
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: #4A5568; color: white; padding: 20px; text-align: center; }
    .content { padding: 20px; background: #F7FAFC; }
    .footer { text-align: center; padding: 20px; color: #718096; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Köszönjük megkeresését!</h1>
    </div>
    <div class="content">
      <p>Kedves {{name}}!</p>
      <p>Köszönjük, hogy felvette velünk a kapcsolatot. Üzenetét megkaptuk és hamarosan válaszolunk.</p>
      <p><strong>Az Ön üzenete:</strong></p>
      <blockquote style="background: white; padding: 15px; border-left: 4px solid #4A5568;">
        {{message}}
      </blockquote>
      <p>Üdvözlettel,<br><strong>Gállné Busai Barbara</strong></p>
    </div>
    <div class="footer">
      Ez egy automatikus üzenet, kérjük ne válaszoljon rá.<br>
      © 2025 Gállné Busai Barbara
    </div>
  </div>
</body>
</html>
```

**2. Esemény regisztráció megerősítés**
```html
<!-- templates/registration-confirmation.html -->
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: #2D3748; color: white; padding: 20px; text-align: center; }
    .event-details { background: #EDF2F7; padding: 20px; margin: 20px 0; border-radius: 8px; }
    .event-details strong { color: #2D3748; }
    .highlight { background: #FED7D7; padding: 10px; border-left: 4px solid #F56565; margin: 15px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>✅ Sikeres regisztráció</h1>
    </div>
    <div class="content">
      <p>Kedves {{full_name}}!</p>
      <p>Örömmel értesítjük, hogy sikeresen regisztrált a következő programunkra:</p>

      <div class="event-details">
        <h2>{{event_title}}</h2>
        <p><strong>📅 Időpont:</strong> {{event_date}}</p>
        <p><strong>📍 Helyszín:</strong> {{location}}</p>
        {{#if address}}
        <p><strong>🗺️ Cím:</strong> {{address}}</p>
        {{/if}}
        {{#if price}}
        <p><strong>💰 Részvételi díj:</strong> {{price}} Ft</p>
        {{/if}}
      </div>

      <p><strong>Regisztrációs azonosító:</strong> #{{registration_id}}</p>

      <div class="highlight">
        <strong>⚠️ Fontos információ:</strong><br>
        A program kezdete előtt 1 héttel részletes információkat küldünk a helyszínről,
        menetrendről és esetleges előkészületekről.
      </div>

      <p>Ha kérdése van, bátran keressen minket:</p>
      <p>
        📧 Email: info@busaibarbara.hu<br>
        📱 Telefon: +36 30 123 4567
      </p>

      <p>Üdvözlettel,<br><strong>Gállné Busai Barbara</strong></p>
    </div>
    <div class="footer">
      © 2025 Gállné Busai Barbara<br>
      <a href="{{website_url}}">busaibarbara.hu</a>
    </div>
  </div>
</body>
</html>
```

#### 3.3.3 Implementáció (PHP)

```php
// app/Mail/ContactConfirmation.php
namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ContactConfirmation extends Mailable
{
    use Queueable, SerializesModels;

    public $name;
    public $messageBody;

    public function __construct($name, $messageBody)
    {
        $this->name = $name;
        $this->messageBody = $messageBody;
    }

    public function envelope()
    {
        return new Envelope(
            subject: 'Köszönjük megkeresését',
        );
    }

    public function content()
    {
        return new Content(
            view: 'emails.contact.confirmation',
        );
    }
}

// app/Http/Controllers/ContactController.php
namespace App\Http\Controllers;

use App\Mail\ContactConfirmation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;

class ContactController extends Controller
{
    public function submit(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|min:2|max:255',
            'email' => 'required|email',
            'message' => 'required|string|min:10|max:2000',
        ]);

        // ... store submission in database ...

        // Send confirmation email to user
        Mail::to($validated['email'])->send(new ContactConfirmation($validated['name'], $validated['message']));

        // Send notification email to admin
        // ...

        return response()->json(['success' => true, 'message' => 'Üzenet elküldve!']);
    }
}
```

---

## 4. PHASE 2: Fejlett Funkciók (MEDIUM Priority)

### 4.1 Content Management System (CMS)

#### 4.1.1 Üzleti Követelmények
- Admin képes szerkeszteni a weboldal tartalmát kód módosítás nélkül
- Tartalom verziózása (rollback lehetőség)
- Előnézeti funkció publikálás előtt
- Gyors tartalom frissítés (30 másodperc alatt)

#### 4.1.2 Adatbázis Séma

```sql
-- Tartalom szekciók tárolása
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

-- Tartalom verzió történet (rollback támogatás)
CREATE TABLE content_history (
    id SERIAL PRIMARY KEY,
    section_key VARCHAR(100) NOT NULL,
    content JSONB NOT NULL,
    version INTEGER NOT NULL,
    edited_by VARCHAR(255),
    edit_description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_content_key ON content_sections(section_key);
CREATE INDEX idx_content_published ON content_sections(is_published);
CREATE INDEX idx_history_key ON content_history(section_key, version DESC);

-- Trigger: minden módosításnál mentés a history táblába
CREATE OR REPLACE FUNCTION save_content_history()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO content_history (section_key, content, version, edited_by)
    VALUES (NEW.section_key, NEW.content, NEW.version, NEW.last_edited_by);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER save_content_history_trigger
AFTER UPDATE ON content_sections
FOR EACH ROW
WHEN (OLD.content IS DISTINCT FROM NEW.content)
EXECUTE FUNCTION save_content_history();
```

#### 4.1.3 API Endpoints

```
GET /api/content/:section - Publikus tartalom lekérése
GET /api/admin/content - Összes tartalom (admin)
PUT /api/admin/content/:section - Tartalom frissítése
GET /api/admin/content/:section/history - Verzió történet
POST /api/admin/content/:section/rollback/:version - Visszaállás régi verzióra
```

#### 4.1.4 Migrációs Terv

A jelenlegi `/public/database.json` tartalmát át kell vezetni az adatbázisba:

```sql
-- Meglévő JSON szakaszok importálása
INSERT INTO content_sections (section_key, content) VALUES
('hero', '{"title": "A bizalom csodákat tesz.", "subtitle": "Szeretettel köszöntöm..."}'),
('about', '{"title": "Tanulmányaim", "sections": [...]}'),
('services', '[{"id": 1, "title": "Boldogok a békességszerzők", ...}]'),
('princesses', '{"id": 1, "title": "Áldott királylányok", ...}'),
('contact', '{"p1": "Ha kérdése van...", "email": "info@busaibarbara.hu", ...}'),
('footer', '{"copyright": "© 2025 Gállné Busai Barbara", ...}');
```

---

### 4.2 Admin Dashboard

#### 4.2.1 Funkciók
- Bejelentkezési rendszer (email + jelszó)
- Kapcsolatfelvételi üzenetek megtekintése
- Eseményregisztrációk kezelése
- Tartalom szerkesztése
- Statisztikák megtekintése

#### 4.2.2 Admin User Séma

```sql
CREATE TABLE admin_users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- bcrypt hash
    full_name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'editor', -- admin, editor
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Első admin user létrehozása
INSERT INTO admin_users (email, password_hash, full_name, role)
VALUES ('info@busaibarbara.hu', '$2b$10$...', 'Gállné Busai Barbara', 'admin');
```

#### 4.2.3 Authentikáció

**Javasolt megoldás: JWT (JSON Web Tokens)**

Mivel a Lumen egy állapotmentes (stateless) micro-framework, a JWT egy kiváló választás az API végpontok védelmére.

```php
// app/Http/Controllers/AuthController.php
namespace App\Http\Controllers;

use App\Models\AdminUser;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Firebase\JWT\JWT;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $this->validate($request, [
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = AdminUser::where('email', $request->input('email'))->first();

        if (!$user || !Hash::check($request->input('password'), $user->password_hash)) {
            return response()->json(['error' => 'Invalid credentials'], 401);
        }

        $payload = [
            'sub' => $user->id,
            'name' => $user->full_name,
            'iat' => time(),
            'exp' => time() + 60*60*7 // 7 days
        ];

        $jwt = JWT::encode($payload, env('JWT_SECRET'), 'HS256');

        return response()->json(['token' => $jwt]);
    }
}

// app/Http/Middleware/JwtMiddleware.php
namespace App\Http\Middleware;

use Closure;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtMiddleware
{
    public function handle($request, Closure $next)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(['error' => 'Token not provided'], 401);
        }

        try {
            $credentials = JWT::decode($token, new Key(env('JWT_SECRET'), 'HS256'));
        } catch (\Exception $e) {
            return response()->json(['error' => 'Provided token is invalid.'], 400);
        }

        $request->auth = $credentials;

        return $next($request);
    }
}
```

---

### 4.3 Analitika

#### 4.3.1 Követendő Metrikák
- Oldalmegtekintések
- Egyedi látogatók
- Esemény regisztrációk száma
- Kapcsolatfelvételi űrlap kitöltések
- Legnépszerűbb oldalak
- Forgalom forrása (referrer)

#### 4.3.2 Adatbázis Séma

```sql
CREATE TABLE analytics_events (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL, -- page_view, button_click, form_submit
    event_data JSONB,
    page_path VARCHAR(500),
    session_id VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    referrer TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_analytics_type ON analytics_events(event_type, created_at DESC);
CREATE INDEX idx_analytics_session ON analytics_events(session_id);
CREATE INDEX idx_analytics_date ON analytics_events(DATE(created_at));

-- Materialized view gyors statisztikákhoz
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

-- Frissítés naponta (cronjob vagy manuálisan)
REFRESH MATERIALIZED VIEW CONCURRENTLY daily_analytics;
```

---

### 4.4 Newsletter Feliratkozás

#### 4.4.1 Adatbázis Séma

```sql
CREATE TABLE newsletter_subscribers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'active', -- active, unsubscribed, bounced
    subscription_source VARCHAR(100), -- website, event_registration
    verified BOOLEAN DEFAULT false,
    verification_token VARCHAR(255),
    unsubscribe_token VARCHAR(255) UNIQUE,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unsubscribed_at TIMESTAMP,

    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_newsletter_status ON newsletter_subscribers(status);
CREATE INDEX idx_newsletter_email ON newsletter_subscribers(email);
```

#### 4.4.2 Double Opt-in Flow

1. Felhasználó megadja az email címét
2. Rendszer küld egy megerősítő emailt
3. Felhasználó kattint a megerősítő linkre
4. Email cím aktiválva, feliratkozás aktív

---

## 5. PHASE 3: Opcionális Funkciók (LOW Priority)

### 5.1 Vélemények/Visszajelzések (Testimonials)

```sql
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

CREATE INDEX idx_testimonials_approved ON testimonials(is_approved, created_at DESC);
```

### 5.2 Fizetési Integráció

**Opciók:**
- **Stripe:** Nemzetközi kártyás fizetés
- **Barion:** Magyar fizetési megoldás
- **SimplePay (OTP):** Magyar piac

```sql
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    registration_id INTEGER REFERENCES event_registrations(id),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'HUF',
    payment_method VARCHAR(50), -- card, transfer, cash
    payment_provider VARCHAR(50), -- stripe, barion
    transaction_id VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending', -- pending, completed, failed, refunded
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 6. Technológiai Stack

### 6.1 Backend Framework

**Választás: PHP + Lumen**

**Indoklás:**
- A Laravel pehelysúlyú, kifejezetten API-k és microservice-ek számára optimalizált változata.
- Rendkívül gyors, így alacsony válaszidőt biztosít az API-nak.
- Mivel a hosting környezet PHP-t támogat, a Lumen ideális választás.
- A Laravel komponenseire épül, így a tudás nagy része átültethető.

**Alternatívák:**
- **Laravel:** A teljes Laravel keretrendszer, ha a jövőben szükség lenne a benne rejlő extra funkciókra (pl. Blade, session, stb.).
- **Slim:** Egy másik népszerű, minimalista micro-framework.

### 6.2 Adatbázis

**Választás: PostgreSQL 15+**

**Indoklás:**
- Erős ACID compliance (adatintegritás)
- JSONB támogatás (rugalmas tartalomkezelés)
- Kiváló teljesítmény és skálázhatóság
- Ingyenes és open-source
- Gazdag feature set (triggerek, funkciók, indexek)

### 6.3 Függőségek (Composer)

```json
{
  "require": {
    "php": "^8.1",
    "laravel/lumen-framework": "^10.0",
    "illuminate/database": "^10.0",
    "illuminate/validation": "^10.0",
    "illuminate/mail": "^10.0",
    "vlucas/phpdotenv": "^5.5",
    "guzzlehttp/guzzle": "^7.2",
    "firebase/php-jwt": "^6.3"
  },
  "require-dev": {
    "fakerphp/faker": "^1.9.1",
    "mockery/mockery": "^1.4.4",
    "phpunit/phpunit": "^10.0"
  }
}
```

### 6.4 Környezeti Változók

```bash
# .env.example

APP_NAME=BarbiVue
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=barbivue_db
DB_USERNAME=user
DB_PASSWORD=password

SESSION_DRIVER=cookie
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=smtp.sendgrid.net
MAIL_PORT=587
MAIL_USERNAME=apikey
MAIL_PASSWORD=your-sendgrid-api-key
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@busaibarbara.hu"
MAIL_FROM_NAME="${APP_NAME}"

ADMIN_EMAIL=info@busaibarbara.hu

FRONTEND_URL=http://localhost:5173

SANCTUM_STATEFUL_DOMAINS="${FRONTEND_URL}"
```

---

## 7. Deployment

### 7.1 Architektúra

**Ajánlott: Szeparált Frontend + Backend**

```
┌─────────────────┐
│   Frontend      │  (pl. Vercel, Netlify)
│   Vue.js SPA    │  - Static hosting
│   Port: 443     │  - CDN
└────────┬────────┘
         │ HTTPS
         ▼
┌─────────────────┐
│   Backend API   │  (PHP Hosting)
│   Laravel       │  - REST API
│   Port: 443     │  - Authentication
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   PostgreSQL    │  (Managed Database)
│   Database      │
└─────────────────┘
```

**Environment Variables beállítása:**

*Backend (.env):*
```
DB_CONNECTION=pgsql
DB_HOST=...
DB_DATABASE=...
DB_USERNAME=...
DB_PASSWORD=...

SANCTUM_STATEFUL_DOMAINS=https://busaibarbara.hu
FRONTEND_URL=https://busaibarbara.hu
```

*Frontend (.env):*
```
VITE_API_URL=https://api.busaibarbara.hu
```

---

## 8. Biztonság

### 8.1 Kritikus Biztonsági Intézkedések

#### 8.1.1 SQL Injection Védelem
```php
// ❌ ROSSZ - SQL injection veszély
DB::select("SELECT * FROM users WHERE email = '{$email}'");

// ✅ JÓ - Parameterized query (Eloquent ORM)
$user = User::where('email', $email)->first();

// ✅ JÓ - Parameterized query (Query Builder)
$user = DB::table('users')->where('email', $email)->first();
```

#### 8.1.2 XSS (Cross-Site Scripting) Védelem
```php
// Input sanitization
$message = htmlspecialchars($request->input('message'), ENT_QUOTES, 'UTF-8');
```

#### 8.1.3 CSRF Védelem

Mivel a Lumen API állapotmentes (stateless) és JWT-t használ, a hagyományos, session-alapú CSRF védelem nem alkalmazható. A védelem a következő rétegekből áll:

1.  **CORS (Cross-Origin Resource Sharing):** Megfelelő CORS beállításokkal csak a megbízható frontend domain-ről érkezhetnek kérések.
2.  **SameSite Cookie Attribútum:** Bár a JWT-t általában a `Authorization` fejlécben küldik, ha mégis cookie-t használunk, a `SameSite=Strict` vagy `SameSite=Lax` beállítások segítenek a CSRF támadások kivédésében.
3.  **Rövid lejáratú tokenek:** A JWT tokenek lejárati idejének rövidre állítása csökkenti a támadási felületet.

#### 8.1.4 Rate Limiting

```php
// app/Providers/RouteServiceProvider.php
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

public function boot()
{
    RateLimiter::for('api', function (Request $request) {
        return Limit::perMinute(60)->by($request->ip());
    });

    RateLimiter::for('contact', function (Request $request) {
        return Limit::perHour(3)->by($request->ip());
    });
}

// routes/api.php
Route::post('/contact', [ContactController::class, 'submit'])->middleware('throttle:contact');
```

#### 8.1.5 CORS Konfiguráció

```php
// config/cors.php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [env('FRONTEND_URL', 'http://localhost:5173')],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```



### 8.2 Biztonsági Checklist

- [ ] SQL injection védelem (parameterized queries)
- [ ] XSS védelem (input sanitization)
- [ ] CSRF védelem (CSRF tokens)
- [ ] Rate limiting (minden public endpoint-ra)
- [ ] CORS megfelelően konfigurálva
- [ ] Helmet.js beállítva
- [ ] Environment variables használata
- [ ] .env fájl .gitignore-ban
- [ ] Jelszavak bcrypt hash-elve
- [ ] Database user korlátozott jogokkal
- [ ] HTTPS kényszerítés production-ben
- [ ] Session cookies secure és httpOnly
- [ ] JWT token expiration beállítva
- [ ] Input validation minden endpoint-on
- [ ] Error messages nem árulnak el érzékeny infót

---

## 9. Teljesítmény Optimalizálás

### 9.1 Database Optimalizálás

#### 9.1.1 Index Stratégia
```sql
-- Gyakran lekérdezett oszlopok indexelése
CREATE INDEX idx_events_date_status ON events(event_date, status)
WHERE status = 'upcoming';

-- Partial index (csak aktív rekordokra)
CREATE INDEX idx_active_registrations ON event_registrations(event_id)
WHERE status IN ('pending', 'confirmed');

-- Email lookup gyorsítása
CREATE INDEX idx_registrations_email ON event_registrations(email);

-- Compound index több feltételhez
CREATE INDEX idx_contact_status_date ON contact_submissions(status, created_at DESC);
```

#### 9.1.2 Query Optimalizálás
```sql
-- Query teljesítmény elemzése
EXPLAIN ANALYZE
SELECT e.*, COUNT(r.id) as registration_count
FROM events e
LEFT JOIN event_registrations r ON e.id = r.event_id
WHERE e.status = 'upcoming'
GROUP BY e.id;

-- N+1 query problémák elkerülése (JOIN használat)
-- Aggregációk használata COUNT helyett, ahol lehet
```

#### 9.1.3 Connection Pooling
```javascript
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20, // Maximum 20 connection
  idleTimeoutMillis: 30000, // 30 másodperc idle után lezárás
  connectionTimeoutMillis: 2000, // 2 másodperc timeout
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Pooled connection használata
const client = await pool.connect();
try {
  const result = await client.query('SELECT * FROM events');
  return result.rows;
} finally {
  client.release(); // Connection visszaadása a pool-ba
}
```

### 9.2 API Caching

#### 9.2.1 Redis Cache (opcionális)
```javascript
const redis = require('redis');
const client = redis.createClient({
  url: process.env.REDIS_URL
});

await client.connect();

// Cache middleware
async function cacheMiddleware(req, res, next) {
  const key = `cache:${req.originalUrl}`;
  const cached = await client.get(key);

  if (cached) {
    return res.json(JSON.parse(cached));
  }

  // Override res.json to cache the response
  const originalJson = res.json.bind(res);
  res.json = (data) => {
    client.setEx(key, 300, JSON.stringify(data)); // 5 min cache
    originalJson(data);
  };

  next();
}

// Használat
app.get('/api/events', cacheMiddleware, async (req, res) => {
  // ...
});
```

#### 9.2.2 HTTP Cache Headers
```javascript
// Static content aggressive caching
app.use('/static', express.static('public', {
  maxAge: '1y',
  immutable: true
}));

// API response cache headers
app.get('/api/events', (req, res) => {
  res.set('Cache-Control', 'public, max-age=300'); // 5 min
  // ...
});
```

### 9.3 Response Compression
```javascript
const compression = require('compression');

app.use(compression({
  level: 6, // Compression level (0-9)
  threshold: 1024, // Csak 1KB feletti válaszokat tömörít
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  }
}));
```

### 9.4 Pagination
```javascript
// GET /api/registrations?page=1&limit=50
app.get('/api/registrations', async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = Math.min(parseInt(req.query.limit) || 50, 100); // Max 100
  const offset = (page - 1) * limit;

  const result = await pool.query(
    'SELECT * FROM event_registrations ORDER BY created_at DESC LIMIT $1 OFFSET $2',
    [limit, offset]
  );

  const totalResult = await pool.query('SELECT COUNT(*) FROM event_registrations');
  const total = parseInt(totalResult.rows[0].count);

  res.json({
    data: result.rows,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit)
    }
  });
});
```

---

## 10. Monitoring & Logging

### 10.1 Application Logging (Winston)

```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'barbivue-api' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
  ]
});

// Console logging development-ben
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}

// Használat
logger.info('User registered for event', { eventId: 123, userId: 456 });
logger.error('Database connection failed', { error: err.message });
```

### 10.2 HTTP Request Logging (Morgan)
```javascript
const morgan = require('morgan');

// Production: JSON format
if (process.env.NODE_ENV === 'production') {
  app.use(morgan('combined', {
    stream: { write: (message) => logger.info(message.trim()) }
  }));
} else {
  // Development: színes konzol output
  app.use(morgan('dev'));
}
```

### 10.3 Error Handling Middleware
```javascript
// Centralized error handler
app.use((err, req, res, next) => {
  logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
    url: req.originalUrl,
    method: req.method,
    ip: req.ip
  });

  // Ne árulj el érzékeny infót production-ben
  const errorResponse = process.env.NODE_ENV === 'production'
    ? { error: 'Internal server error' }
    : { error: err.message, stack: err.stack };

  res.status(err.status || 500).json(errorResponse);
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});
```

### 10.4 Health Check Endpoint
```javascript
app.get('/api/health', async (req, res) => {
  try {
    // Database check
    await pool.query('SELECT 1');

    // Email service check (opcionális)
    // await transporter.verify();

    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV
    });
  } catch (error) {
    logger.error('Health check failed', { error: error.message });
    res.status(503).json({
      status: 'unhealthy',
      error: error.message
    });
  }
});
```

### 10.5 Uptime Monitoring

**Ajánlott szolgáltatások:**
- **UptimeRobot** (ingyenes, 5 perces check)
- **Better Uptime** (szebb UI, fizetős)
- **Pingdom** (részletes analitika)

**Setup:**
1. Regisztráció a választott szolgáltatásnál
2. Health check endpoint hozzáadása (`/api/health`)
3. Email/SMS/Slack értesítések beállítása
4. 5 perces check interval

---

## 11. Testing Stratégia

### 11.1 Unit Testing (Jest)

```javascript
// tests/services/email.test.js
const { sendContactConfirmation } = require('../../services/email');

describe('Email Service', () => {
  test('should send contact confirmation email', async () => {
    const result = await sendContactConfirmation({
      name: 'Teszt János',
      email: 'test@example.com',
      message: 'Teszt üzenet'
    });

    expect(result.success).toBe(true);
    expect(result.messageId).toBeDefined();
  });
});
```

### 11.2 Integration Testing

```javascript
// tests/api/contact.test.js
const request = require('supertest');
const app = require('../../app');

describe('POST /api/contact', () => {
  test('should create contact submission', async () => {
    const response = await request(app)
      .post('/api/contact')
      .send({
        name: 'Teszt János',
        email: 'test@example.com',
        message: 'Teszt üzenet a kapcsolatfelvételi űrlapon'
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  test('should reject invalid email', async () => {
    const response = await request(app)
      .post('/api/contact')
      .send({
        name: 'Teszt János',
        email: 'invalid-email',
        message: 'Teszt üzenet'
      });

    expect(response.status).toBe(400);
  });
});
```

### 11.3 End-to-End Testing (Playwright)

```javascript
// tests/e2e/contact-form.spec.js
const { test, expect } = require('@playwright/test');

test('user can submit contact form', async ({ page }) => {
  await page.goto('http://localhost:5173');

  await page.fill('input[name="name"]', 'Teszt János');
  await page.fill('input[name="email"]', 'test@example.com');
  await page.fill('textarea[name="message"]', 'Teszt üzenet');

  await page.click('button[type="submit"]');

  await expect(page.locator('.success-message')).toBeVisible();
});
```

---

## 12. Implementációs Timeline

### 12.1 Fázisolt Megvalósítás

#### **Week 1-2: Alapok (Foundation)**
- ✅ PostgreSQL adatbázis létrehozása
- ✅ Backend projekt struktúra felállítása
- ✅ Database kapcsolat és connection pool
- ✅ Environment variables setup
- ✅ Alapvető middleware-ek (CORS, Helmet, Rate Limiting)

**Deliverable:** Működő backend skeleton, database kapcsolat

---

#### **Week 3-4: Kapcsolatfelvételi Űrlap (Phase 1.1)**
- [ ] `contact_submissions` tábla létrehozása
- [ ] POST /api/contact endpoint implementálása
- [ ] Input validáció (express-validator)
- [ ] Email service setup (SendGrid/Nodemailer)
- [ ] Email sablonok (contact-confirmation, admin-notification)
- [ ] Frontend ContactForm komponens
- [ ] Rate limiting és spam védelem

**Deliverable:** Működő kapcsolatfelvételi űrlap email értesítésekkel

#### **Week 5-6: Admin Authentikáció (Phase 1.2)**
- [ ] `admin_users` tábla létrehozása
- [ ] JWT authentikáció implementálása
- [ ] POST /api/admin/login endpoint
- [ ] Auth middleware
- [ ] Jelszó hash-elés (bcrypt)
- [ ] Frontend login komponens
- [ ] Protected routes frontend-en

**Deliverable:** Biztonságos admin bejelentkezés

---

#### **Week 7-9: Content Management System (Phase 2.1)**
- [ ] `content_sections` és `content_history` táblák
- [ ] Meglévő tartalom migrálása JSON-ból DB-be
- [ ] GET /api/content/:section endpoint (public)
- [ ] PUT /api/admin/content/:section endpoint (protected)
- [ ] GET /api/admin/content/:section/history endpoint
- [ ] POST /api/admin/content/:section/rollback/:version
- [ ] Frontend admin CMS interface
- [ ] Content preview funkció

**Deliverable:** Dinamikus tartalom szerkesztés admin felületen

#### **Week 10-12: Eseményregisztrációs Rendszer (Phase 2.2)**
- [ ] `events` és `event_registrations` táblák létrehozása
- [ ] Meglévő események migrálása JSON-ból DB-be
- [ ] GET /api/events endpoint
- [ ] GET /api/events/:slug endpoint
- [ ] POST /api/events/:slug/register endpoint
- [ ] Üzleti logika (létszámkorlát, határidő check)
- [ ] Email sablonok (registration-confirmation)
- [ ] Frontend EventsList és RegistrationForm komponensek
- [ ] Admin endpoint: GET /api/admin/events/:id/registrations

**Deliverable:** Teljes eseményregisztrációs rendszer, Google Forms replacement

#### **Week 13-15: Admin Dashboard (Phase 2.3)**
- [ ] Admin dashboard layout (Vue komponens)
- [ ] Kapcsolatfelvételi üzenetek listázása
- [ ] Esemény regisztrációk listázása és kezelése
- [ ] Események CRUD műveletek admin felületen
- [ ] Statisztikák (összesített adatok)
- [ ] Export funkciók (CSV export)

**Deliverable:** Teljes admin dashboard

#### **Week 16-17: Analitika (Phase 2.4 - Optional)**
- [ ] `analytics_events` tábla
- [ ] Analytics tracking implementálása frontend-en
- [ ] POST /api/analytics/event endpoint
- [ ] Materialized view daily statisztikákhoz
- [ ] Admin analytics dashboard
- [ ] Grafikonok (Chart.js vagy ApexCharts)

**Deliverable:** Használati statisztikák követése

---

#### **Week 18+: További Funkciók (Phase 3 - Optional)**
- [ ] Newsletter feliratkozás
- [ ] Vélemények/visszajelzések rendszer
- [ ] Fizetési integráció (Stripe/Barion)
- [ ] User authentication (participant portal)

**Deliverable:** Extra funkciók igény szerint

---

### 12.2 Quick Win: Minimal Viable Product (MVP)

**Ha gyors eredményt szeretnél (2-3 hét):**

1. **Week 1:**
   - Database setup
   - Kapcsolatfelvételi űrlap backend + frontend
   - Email értesítések

2. **Week 2:**
   - Események táblák létrehozása
   - Events API endpoints
   - Frontend események listázása

3. **Week 3:**
   - Regisztrációs rendszer
   - Email confirmations
   - Deployment

**MVP Scope:**
- ✅ Kapcsolatfelvételi űrlap
- ✅ Esemény regisztrációk
- ✅ Email értesítések
- ❌ Admin dashboard (manuális DB kezelés ideiglenesen)
- ❌ CMS (tartalom még JSON-ban)

---

## 13. Költségvetés

### 13.1 Infrastruktúra Költségek (Havi)

#### **Option 1: Serverless Stack (Kezdő, Low Cost)**

| Szolgáltatás | Tier | Ár | Limit | Megjegyzés |
|--------------|------|-----|-------|------------|
| **Vercel** | Hobby | $0 | 100GB bandwidth | Frontend hosting |
| **Railway** | Trial | $5 | 500 órág futás | Backend hosting |
| **Neon** | Free | $0 | 0.5GB storage | PostgreSQL |
| **SendGrid** | Free | $0 | 100 email/nap | Email service |
| **Total** | | **$5/hó** | | ✅ Induláshoz tökéletes |

**Skálázási korlátok:**
- 3000 email/hó (100/nap × 30 nap)
- 500 óra backend futás (~20 nap folyamatos)
- 0.5GB adatbázis (~10,000 regisztráció)

---

#### **Option 2: Production Ready Stack**

| Szolgáltatás | Tier | Ár | Limit | Megjegyzés |
|--------------|------|-----|-------|------------|
| **Vercel** | Pro | $20 | 1TB bandwidth | Unlimited builds |
| **Railway** | Developer | $10 | 2000 óra futás | 8GB RAM |
| **Neon** | Scale | $19 | 3GB storage | Auto-scaling |
| **SendGrid** | Essentials | $15 | 50k email/hó | Dedicated IP opcionális |
| **Total** | | **$64/hó** | | ✅ Production scale |

**Kapacitás:**
- 50,000 email/hó
- 2000 óra backend futás (folyamatos)
- 3GB adatbázis (~100,000 regisztráció)

---

#### **Option 3: VPS (Maximum Control)**

| Szolgáltatás | Tier | Ár | Specifikáció |
|--------------|------|-----|--------------|
| **Hetzner VPS** | CX11 | €4.15 | 2GB RAM, 20GB SSD |
| **Domain** | .hu | €10/év | busaibarbara.hu |
| **SendGrid** | Free | $0 | 100 email/nap |
| **Total** | | **€5/hó** | ✅ Cheapest option |

**Setup komplexitás:** ⚠️ Magasabb (Linux server admin szükséges)

---

### 13.2 Fejlesztési Költségek

**Ha külsős fejlesztőt bíznál meg:**

| Fázis | Órabecslés | Óradíj (Ft) | Költség |
|-------|------------|-------------|---------|
| **Phase 1: Alapok** | 80-100 óra | 8,000-15,000 | 640k - 1.5M |
| **Phase 2: CMS + Admin** | 60-80 óra | 8,000-15,000 | 480k - 1.2M |
| **Phase 3: Extra funkciók** | 40-60 óra | 8,000-15,000 | 320k - 900k |
| **Összesen (teljes)** | 180-240 óra | | **1.44M - 3.6M Ft** |

**MVP (Phase 1 only):** 640k - 1.5M Ft

---

### 13.3 Karbantartási Költségek (Éves)

| Tétel | Gyakoriság | Költség/év |
|-------|-----------|------------|
| **Hosting (Vercel+Railway+Neon)** | Havi | $60-120 / €720-1440 |
| **Domain renewal** | Évente | €10 |
| **SSL Certificate** | Évente | €0 (Let's Encrypt) |
| **Backup storage** | Havi | €5/hó = €60/év |
| **Monitoring (UptimeRobot)** | Havi | €0 (free tier) |
| **Minor updates & fixes** | Eseti | 200k-500k Ft |
| **Összesen** | | **€800-1500 + 200-500k Ft** |

---

## 14. Kockázatok és Mitigálás

### 14.1 Technikai Kockázatok

| Kockázat | Valószínűség | Hatás | Mitigálás |
|----------|--------------|-------|-----------|
| **Adatvesztés** | Alacsony | Kritikus | Napi automatikus backup, point-in-time recovery (Neon/Supabase) |
| **Email delivery issues** | Közepes | Magas | SendGrid + fallback SMTP, email queue retry logic |
| **API downtime** | Alacsony | Magas | Health monitoring, auto-restart (Railway/Render), backup hosting |
| **Security breach** | Közepes | Kritikus | Input validation, rate limiting, security audit, WAF (Railway/Cloudflare) |
| **Database performance** | Közepes | Közepes | Connection pooling, indexek, query optimization, caching |
| **Spam/Bot registrations** | Magas | Közepes | Rate limiting, CAPTCHA, honeypot, email verification |

---

### 14.2 Üzleti Kockázatok

| Kockázat | Valószínűség | Hatás | Mitigálás |
|----------|--------------|-------|-----------|
| **Túl sok regisztráció (capacity)** | Alacsony | Közepes | Auto-scaling (Railway), queue system, waitlist funkció |
| **GDPR compliance issues** | Közepes | Magas | Privacy policy, data retention policy, right to be forgotten implementálása |
| **Költségvetés túllépés** | Közepes | Közepes | Start with free tiers, monitor usage alerts, set billing limits |
| **User adoption failure** | Közepes | Közepes | User testing, feedback loop, gradual rollout, training materials |

---

## 15. GDPR és Adatvédelem

### 15.1 GDPR Követelmények

**Jogalap adatkezeléshez:**
- **Hozzájárulás:** Kapcsolatfelvételi űrlap, newsletter
- **Szerződés teljesítése:** Esemény regisztráció
- **Jogos érdek:** Analytics (anonymizált)

**Implementálandó funkciók:**

#### 15.1.1 Privacy Policy Link
```vue
<form @submit="submitContact">
  <!-- form fields -->
  <label>
    <input type="checkbox" v-model="acceptPrivacy" required />
    Elfogadom az
    <a href="/adatvedelem" target="_blank">adatvédelmi nyilatkozatot</a>
  </label>
  <button :disabled="!acceptPrivacy">Küldés</button>
</form>
```

#### 15.1.2 Right to Data Access
```javascript
// GET /api/gdpr/my-data?email=user@example.com
app.get('/api/gdpr/my-data', async (req, res) => {
  const { email } = req.query;

  // Verify email ownership (send verification link)
  // Then return all data associated with this email

  const contacts = await pool.query(
    'SELECT * FROM contact_submissions WHERE email = $1',
    [email]
  );

  const registrations = await pool.query(
    'SELECT * FROM event_registrations WHERE email = $1',
    [email]
  );

  res.json({
    contact_submissions: contacts.rows,
    event_registrations: registrations.rows
  });
});
```

#### 15.1.3 Right to Deletion
```javascript
// DELETE /api/gdpr/delete-my-data
app.delete('/api/gdpr/delete-my-data', async (req, res) => {
  const { email } = req.body;

  // Verify email ownership first (email verification link)

  await pool.query('DELETE FROM contact_submissions WHERE email = $1', [email]);
  await pool.query('DELETE FROM event_registrations WHERE email = $1', [email]);
  await pool.query('DELETE FROM newsletter_subscribers WHERE email = $1', [email]);

  res.json({ message: 'All data deleted successfully' });
});
```

#### 15.1.4 Data Retention Policy
```sql
-- Automatically delete old contact submissions after 2 years
CREATE OR REPLACE FUNCTION delete_old_contacts()
RETURNS void AS $$
BEGIN
    DELETE FROM contact_submissions
    WHERE created_at < CURRENT_DATE - INTERVAL '2 years'
    AND status IN ('read', 'replied');
END;
$$ LANGUAGE plpgsql;

-- Run monthly via cron
-- 0 0 1 * * psql -U user -d barbivue_db -c "SELECT delete_old_contacts();"
```

#### 15.1.5 Consent Tracking
```sql
-- Track consent for GDPR compliance
CREATE TABLE user_consents (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    consent_type VARCHAR(50) NOT NULL, -- contact_form, newsletter, event_registration
    consented BOOLEAN DEFAULT true,
    consent_text TEXT, -- Full text of privacy policy at time of consent
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_consents_email ON user_consents(email);
```

---

## 16. Dokumentáció

### 16.1 API Dokumentáció

**Javasolt eszközök:**
- **Swagger/OpenAPI:** Automatikus API dokumentáció
- **Postman Collection:** API testing és dokumentáció

#### Swagger Setup
```javascript
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'BarbiVue API',
      version: '1.0.0',
      description: 'Backend API for BarbiVue spiritual events platform'
    },
    servers: [
      { url: 'http://localhost:3000', description: 'Development' },
      { url: 'https://api.busaibarbara.hu', description: 'Production' }
    ]
  },
  apis: ['./routes/*.js']
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
```

#### API Endpoint Dokumentáció Példa
```javascript
/**
 * @swagger
 * /api/contact:
 *   post:
 *     summary: Submit contact form
 *     tags: [Contact]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - message
 *             properties:
 *               name:
 *                 type: string
 *                 minLength: 2
 *                 maxLength: 255
 *               email:
 *                 type: string
 *                 format: email
 *               phone:
 *                 type: string
 *               message:
 *                 type: string
 *                 minLength: 10
 *                 maxLength: 2000
 *     responses:
 *       200:
 *         description: Message sent successfully
 *       400:
 *         description: Validation error
 *       429:
 *         description: Too many requests
 */
router.post('/contact', contactLimiter, ...);
```

---

### 16.2 README.md Frissítés

```markdown
# BarbiVue - Backend

A weboldal backend rendszere PHP + Lumen + PostgreSQL stack-kel.

## Features

- ✅ Kapcsolatfelvételi űrlap email értesítésekkel
- ✅ Esemény regisztrációs rendszer
- ✅ Admin authentikáció (JWT)
- ✅ Content Management System
- ✅ Email notification system (SendGrid)
- ✅ Rate limiting és security

## Tech Stack

- **Backend:** PHP + Lumen
- **Database:** PostgreSQL 15+
- **Email:** SendGrid
- **Auth:** JWT (firebase/php-jwt)
- **Validation:** illuminate/validation

## Setup

### Prerequisites
- PHP 8.1+
- Composer
- PostgreSQL 15+
- SendGrid API key (or SMTP credentials)

### Installation

1. Clone repository
2. Install dependencies:
   ```bash
   composer install
   ```

3. Setup environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. Create database:
   ```bash
   createdb barbivue_db
   ```

5. Run migrations:
   ```bash
   php artisan migrate
   ```

6. Start development server:
   ```bash
   php -S localhost:8000 -t public
   ```

API will be available at `http://localhost:8000`

---

## 17. Összefoglalás

### 17.1 Főbb Eredmények (Expected Outcomes)

**Technikai:**
- ✅ Skálázható backend architektúra
- ✅ Biztonságos adatkezelés (GDPR compliant)
- ✅ Automatizált email kommunikáció
- ✅ Admin kontroll panel
- ✅ 99.5%+ uptime
- ✅ <500ms API response time

**Üzleti:**
- ✅ Professzionális online jelenlét
- ✅ Hatékony eseménykezelés
- ✅ Központi adatbázis (CRM alapok)
- ✅ Gyors tartalomfrissítés (30 másodperc)
- ✅ Email lista építés (newsletter)
- ✅ Mérhetőség (analytics)

**Felhasználói Élmény:**
- ✅ Egyszerű kapcsolatfelvétel
- ✅ Gyors eseményregisztráció
- ✅ Automatikus megerősítés
- ✅ Mobil-barát (responsive)

---

## Appendix

### A. Hasznos Linkek

**Dokumentáció:**
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Lumen Documentation](https://lumen.laravel.com/docs/10.x)
- [SendGrid API Docs](https://docs.sendgrid.com/)
- [JWT (JSON Web Tokens)](https://jwt.io/)

**Security:**
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [PHP Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/PHP_Configuration_Cheat_Sheet.html)

---

## License

Private - © 2025 Gállné Busai Barbara

---

**Dokumentum vége**

*Ez a PRD egy élő dokumentum. Folyamatosan frissítsd a fejlesztés előrehaladtával és új követelmények felmerülésekor.*

**Verzió History:**
- v1.0 (2025-10-01): Kezdeti verzió backend fejlesztési terv

**Kapcsolat:**
- Email: info@busaibarbara.hu
- Weboldal: busaibarbara.hu (hamarosan backend-del 😊)
