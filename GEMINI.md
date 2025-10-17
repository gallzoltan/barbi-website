# GEMINI.md

## Project Overview

This project is a Vue.js single-page application for a mediator's professional website. It is built with Vite and styled with Tailwind CSS. The application is currently a frontend-only implementation, with all dynamic content being loaded from a static `/public/database.json` file.

A detailed Product Requirements Document (`docs/PRD.md`) outlines a comprehensive plan to develop a backend for this application. The plan includes:
- A Node.js (Express) backend.
- A PostgreSQL database.
- Features like a contact form, event registration system, and a content management system (CMS).
- A containerized development environment using Docker/Podman.

## Building and Running

### Prerequisites
- Node.js
- npm (or a compatible package manager)
- Podman (optional, for containerized development)

### Standard Commands

1.  **Install dependencies:**
    ```bash
    npm install
    ```

2.  **Run the development server:**
    ```bash
    npm run dev
    ```

3.  **Build for production:**
    ```bash
    npm run build
    ```

4.  **Preview the production build:**
    ```bash
    npm run preview
    ```

### Containerized Development (using Makefile)

The project includes a `Makefile` to simplify running a containerized development environment.

1.  **Build the development image (if not already built):**
    The `Dockerfile` is configured to use a Node.js 18 image.

2.  **Start the development container:**
    ```bash
    make venv
    ```
    This command will start a Podman container, mount the project directory, and expose the necessary port for the Vite development server.

## Development Conventions

- **Framework:** The project is built with Vue 3, utilizing the Composition API (`<script setup>`).
- **Component Structure:** Components are located in the `src/components/` directory. The main application component is `src/App.vue`.
- **Styling:** Tailwind CSS is used for styling, with the configuration located in `tailwind.config.js`.
- **Application Entrypoint:** The main entry point for the application is `src/main.js`.
- **Backend Plan:** The `docs/PRD.md` file provides a detailed roadmap for future backend development, which should be consulted for any new features.
