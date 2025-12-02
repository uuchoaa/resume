# Resume Project

This project contains two applications:

## 1. Electron App (Active) ⚡

**Location**: `electron-app/`

A modular TypeScript-based Electron application for web scraping with extensible sources and actions.

### Quick Start

```bash
cd electron-app
npm install
npm run build
npm start
```

### Features

- ✅ TypeScript modular architecture
- ✅ W1: Browser with free navigation
- ✅ W2: Control panel with Tailwind UI
- ✅ Extensible sources (LinkedIn, Calendly included)
- ✅ URL-based scenario detection
- ✅ Readers (extract data) and Writers (inject data)
- ✅ Processors for data transformation
- ✅ Test fixtures for local development
- ✅ No external dependencies (Rails removed)

### Documentation

- [README.md](electron-app/README.md) - Full architecture documentation
- [QUICKSTART.md](electron-app/QUICKSTART.md) - Getting started guide
- [ARCHITECTURE.md](electron-app/ARCHITECTURE.md) - Technical details
- [EXAMPLES.md](electron-app/EXAMPLES.md) - Code examples
- [PROJECT_STRUCTURE.md](electron-app/PROJECT_STRUCTURE.md) - File organization

### Current Sources

- **LinkedIn**: Chat extraction, message injection
- **Calendly**: Booking information extraction

### Adding New Sources

1. Create folder: `electron-app/src/sources/YOUR_SOURCE/`
2. Define source, scenarios, readers, and writers
3. Register in `src/sources/index.ts`
4. Build and run

See [EXAMPLES.md](electron-app/EXAMPLES.md) for detailed examples.

---

## 2. Rails App (Legacy) 🗄️

**Location**: `rails-app/`

Original Rails application with models and controllers. Currently not in use but preserved for reference.

---

## Migration Notes

The application has been successfully migrated from a Rails-dependent architecture to a standalone Electron application:

**Before**: Electron (W1, W2) ← HTTP → Rails Server (backend, database)  
**After**: Electron (W1, W2, Main Process with Core Modules)

All functionality now runs locally within Electron with no external server dependencies.
