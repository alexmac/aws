/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './templates/**/*.{html,jinja,j2}'
  ],
  theme: {
    extend: {},
    screens: {
      // 'lt-md': { 'max': '767px' },
      'sm': { 'max': '767px' },
      // => @media (min-width: 640px) { ... }

      'md': '768px',
      // => @media (min-width: 768px) { ... }

      'lg': '1024px',
      // => @media (min-width: 1024px) { ... }

      'xl': '1280px',
      // => @media (min-width: 1280px) { ... }

      '2xl': '1536px',
      // => @media (min-width: 1536px) { ... }
    }
  },
  plugins: [],
}

