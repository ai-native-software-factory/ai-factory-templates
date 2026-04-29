# Vue 3 Web Template Specification

## Overview

This is a production-ready Vue 3 web application template for the ai-factory-templates repository. It provides a modern, scalable frontend foundation using Vue 3 Composition API with TypeScript.

## Tech Stack

| Category | Technology | Version |
|----------|------------|---------|
| Framework | Vue | 3.4.x |
| Build Tool | Vite | 5.x |
| Language | TypeScript | 5.x |
| Router | Vue Router | 4.x |
| State Management | Pinia | 2.1.x |
| UI Library | Element Plus | 2.5.x |
| HTTP Client | Axios | 1.6.x |
| Date Library | dayjs | 1.x |
| Charts | echarts | 5.x |
| Styling | Sass | 1.x |
| Package Manager | pnpm | 8.x |

## Project Structure

```
vue-web/
├── public/
│   └── favicon.ico
├── src/
│   ├── api/              # API modules
│   ├── components/       # Shared components
│   ├── composables/      # Vue composables
│   ├── layouts/          # Layout components
│   ├── router/           # Vue Router config
│   ├── stores/           # Pinia stores
│   ├── styles/           # Global styles
│   ├── types/            # TypeScript types
│   ├── utils/            # Utility functions
│   ├── views/            # Page components
│   ├── App.vue           # Root component
│   └── main.ts           # Application entry
├── index.html
├── package.json
├── tsconfig.json
├── tsconfig.node.json
├── vite.config.ts
├── .env.example
├── .eslintrc.cjs
├── .prettierrc
├── .gitignore
└── README.md
```

## Features

### Core Features
- **Vue 3 Composition API** with `<script setup>` syntax
- **TypeScript** throughout with strict type checking
- **Pinia** for state management with typed stores
- **Vue Router 4** with lazy loading and route guards
- **Axios** with interceptors for API requests
- **Element Plus** component library
- **Auto-import** for components and composables

### Design System
- SCSS with variables, mixins, and global styles
- CSS custom properties for theming
- Responsive layout with sidebar + header structure

### Developer Experience
- ESLint with Vue 3 and TypeScript rules
- Prettier code formatting
- Type checking with vue-tsc
- Vite dev server with proxy support

## API Design

### Request Interceptors
- Attach authentication tokens
- Handle global error cases
- Transform request data

### Response Interceptors
- Handle global error responses
- Transform response data
- Auto-logout on 401 errors

## Routing Structure

```
/                     → HomePage (requires auth)
/login                → LoginPage (public)
/404                  → NotFoundPage (catch-all)
```

Routes are lazy-loaded for optimal performance.

## State Management

### Auth Store
- `token`: string | null
- `user`: User | null
- `isAuthenticated`: boolean
- `login(credentials)`: Promise<void>
- `logout()`: void

### App Store
- `sidebarCollapsed`: boolean
- `loading`: boolean
- `toggleSidebar()`: void
- `setLoading(loading)`: void

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| VITE_API_BASE_URL | API base URL for proxy | /api |
| VITE_APP_TITLE | Application title | Vue App |

## Scripts

| Command | Description |
|---------|-------------|
| pnpm dev | Start development server |
| pnpm build | Build for production |
| pnpm preview | Preview production build |
| pnpm lint | Run ESLint |
| pnpm type-check | Run TypeScript type checking |
