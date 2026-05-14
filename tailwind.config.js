const { scopedPreflightStyles, isolateInsideOfContainer } = require('tailwindcss-scoped-preflight');

/** @type {import('tailwindcss').Config} */
module.exports = {
  prefix: 'tw-',
  content: [
    './engines/jigsaw-engine/app/javascript/jigsaw/**/*.{js,jsx}',
    './engines/jigsaw-engine/app/views/**/*.ruby',
    './engines/jigsaw-engine/jsx/**/*.jsx',
  ],
  safelist: [
    { pattern: /.*/ },
  ],
  corePlugins: {
    container: false,
  },
  theme: {
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      keyframes: {
        'tw-in': {
          from: { opacity: 'var(--tw-enter-opacity, 1)', transform: 'var(--tw-enter-transform)' },
          to: { opacity: '1', transform: 'none' },
        },
        'tw-out': {
          from: { opacity: '1', transform: 'none' },
          to: { opacity: 'var(--tw-exit-opacity, 0)', transform: 'var(--tw-exit-transform)' },
        },
      },
      animation: {
        'tw-in': 'tw-in 150ms ease-out',
        'tw-out': 'tw-out 150ms ease-in',
      },
    },
  },
  plugins: [
    scopedPreflightStyles({
      isolationStrategy: isolateInsideOfContainer('[data-controller~="custom-module"]'),
    }),
  ],
}