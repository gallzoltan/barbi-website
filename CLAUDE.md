# BarbiVue Project

A Vue.js application built with Vite, featuring a responsive design with Tailwind CSS.

## Tech Stack
- Vue 3
- Vite (build tool)
- Tailwind CSS (styling)
- Vue3 Carousel (carousel component)
- Lucide Vue Next (icons)

## Quick Start

### Development
```bash
npm run dev
```
Starts the development server with hot reload at http://localhost:5173

### Build
```bash
npm run build
```
Builds the application for production to the `dist/` directory

### Preview
```bash
npm run preview
```
Preview the production build locally

## Project Structure
```
├── src/
│   ├── App.vue          # Main application component
│   ├── main.js          # Application entry point
│   ├── style.css        # Global styles
│   ├── components/      # Vue components
│   └── assets/          # Static assets
├── public/              # Public static files
├── dist/                # Production build output
├── index.html           # HTML template
├── vite.config.js       # Vite configuration
├── tailwind.config.js   # Tailwind CSS configuration
└── postcss.config.js    # PostCSS configuration
```

## Commands for Claude Code

When working on this project, these are the common commands to run:

### Development Commands
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build

### Linting/Testing
No specific linting or testing commands configured. Add them to package.json if needed.

## Notes
- Uses Vue 3 Composition API
- Styled with Tailwind CSS utility classes
- Server configured to listen on all interfaces (host: true)
- Project name: "mediator-landing"