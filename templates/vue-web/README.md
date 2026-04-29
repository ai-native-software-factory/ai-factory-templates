# Vue 3 Web Template

A production-ready Vue 3 web application template with TypeScript, Vite, Pinia, Vue Router, and Element Plus.

## Features

- **Vue 3** with Composition API and `<script setup>` syntax
- **TypeScript** for type safety
- **Vite 5** for fast development and optimized builds
- **Pinia** for state management
- **Vue Router 4** with lazy loading and route guards
- **Element Plus** component library
- **Axios** with interceptors for API requests
- **SCSS** for styling with variables and mixins
- **ESLint + Prettier** for code quality

## Getting Started

### Prerequisites

- Node.js >= 18.0.0
- pnpm >= 8.0.0

### Installation

```bash
# Install dependencies
pnpm install

# Start development server
pnpm dev

# Build for production
pnpm build

# Preview production build
pnpm preview

# Run type checking
pnpm type-check

# Run linter
pnpm lint
```

### Project Structure

```
src/
├── api/              # API modules
├── components/       # Shared components
├── composables/      # Vue composables
├── layouts/          # Layout components
├── router/           # Vue Router config
├── stores/           # Pinia stores
├── styles/           # Global styles
├── types/            # TypeScript types
├── utils/            # Utility functions
├── views/            # Page components
├── App.vue           # Root component
└── main.ts           # Application entry
```

### Environment Variables

Create a `.env` file based on `.env.example`:

```env
VITE_API_BASE_URL=http://localhost:8080
VITE_APP_TITLE=Vue Application
```

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start development server |
| `pnpm build` | Build for production |
| `pnpm preview` | Preview production build |
| `pnpm lint` | Run ESLint |
| `pnpm type-check` | Run TypeScript type checking |

## License

MIT
