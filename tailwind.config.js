/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
        },
        accent: {
          500: '#f97316',
          600: '#ea580c',
        }
      },
      maxWidth: {
        'content': '1200px',
        'content-narrow': '800px',
      },
      spacing: {
        'section': '5rem', // 80px
        'section-sm': '3rem', // 48px
      }
    },
  },
  plugins: [],
}