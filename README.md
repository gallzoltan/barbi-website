# Vue 3 + Vite

This template should help get you started developing with Vue 3 in Vite. The template uses Vue 3 `<script setup>` SFCs, check out the [script setup docs](https://v3.vuejs.org/api/sfc-script-setup.html#sfc-script-setup) to learn more.

Learn more about IDE Support for Vue in the [Vue Docs Scaling up Guide](https://vuejs.org/guide/scaling-up/tooling.html#ide-support).

```markdown
# BarbiVue - Backend

A weboldal backend rendszere Node.js + PostgreSQL stack-kel.

## Features

- ✅ Kapcsolatfelvételi űrlap email értesítésekkel
- ✅ Esemény regisztrációs rendszer
- ✅ Admin authentikáció (JWT)
- ✅ Content Management System
- ✅ Email notification system (SendGrid)
- ✅ Rate limiting és security

## Tech Stack

- **Backend:** Node.js + Express.js
- **Database:** PostgreSQL 15+
- **Email:** SendGrid / Nodemailer
- **Auth:** JWT (jsonwebtoken)
- **Validation:** express-validator
- **Security:** Helmet, CORS, Rate Limiting

## Setup

### Prerequisites
- Node.js 18+
- PostgreSQL 15+
- SendGrid API key (or SMTP credentials)

### Installation

1. Clone repository
2. Install dependencies:
   ```bash
   npm install
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
   npm run migrate
   ```

6. Start development server:
   ```bash
   npm run dev
   ```

API will be available at `http://localhost:3000`

## API Documentation

Full API documentation available at `/api-docs` (Swagger UI)

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for production deployment instructions.

## License

Private - © 2025 Gállné Busai Barbara
