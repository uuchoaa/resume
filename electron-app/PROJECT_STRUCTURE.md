# Project Structure

## Complete File Tree

```
electron-app/
│
├── 📄 package.json              # Dependencies & scripts
├── 📄 tsconfig.json             # TypeScript config
├── 📄 .gitignore                # Git ignore rules
│
├── 📚 Documentation
│   ├── README.md                # Main documentation
│   ├── QUICKSTART.md            # Getting started guide
│   ├── ARCHITECTURE.md          # Technical architecture
│   ├── EXAMPLES.md              # Code examples
│   ├── SUMMARY.md               # Implementation summary
│   └── PROJECT_STRUCTURE.md     # This file
│
├── 🔧 src/                      # TypeScript source code
│   │
│   ├── 📘 types/
│   │   └── index.ts             # Core type definitions
│   │
│   ├── 🎯 core/                 # Core modules
│   │   ├── source-manager.ts    # Manages sources
│   │   ├── scenario-detector.ts # URL-based detection
│   │   ├── action-executor.ts   # Script execution
│   │   └── data-store.ts        # Session storage
│   │
│   ├── 🌐 sources/              # All sources (extensible)
│   │   │
│   │   ├── index.ts             # Sources registry
│   │   │
│   │   ├── linkedin/            # LinkedIn source
│   │   │   ├── source.ts
│   │   │   └── scenarios/
│   │   │       ├── chat/
│   │   │       │   ├── index.ts
│   │   │       │   ├── readers/
│   │   │       │   │   └── extract-conversation.ts
│   │   │       │   ├── writers/
│   │   │       │   │   └── inject-message.ts
│   │   │       │   └── test-fixtures/
│   │   │       │       └── chat.html
│   │   │       │
│   │   │       └── feed/
│   │   │           ├── index.ts
│   │   │           └── readers/
│   │   │               └── extract-posts.ts
│   │   │
│   │   └── calendly/            # Calendly source (example)
│   │       ├── source.ts
│   │       └── scenarios/
│   │           └── confirmation/
│   │               ├── index.ts
│   │               ├── readers/
│   │               │   └── extract-booking.ts
│   │               └── test-fixtures/
│   │                   └── confirmation.html
│   │
│   ├── ⚙️ processors/           # Data processors
│   │   ├── index.ts             # Processors registry
│   │   ├── summarize.ts         # Summarize data
│   │   └── export-json.ts       # Export to JSON
│   │
│   ├── 🖥️ ui/                   # W2 Control Panel
│   │   ├── w2.html              # UI markup
│   │   └── w2.ts                # UI logic
│   │
│   ├── main.ts                  # Main Electron process
│   └── preload.ts               # IPC bridge
│
├── 📦 dist/                     # Compiled JavaScript (generated)
│   ├── core/
│   ├── sources/
│   ├── processors/
│   ├── ui/
│   ├── types/
│   ├── main.js
│   └── preload.js
│
└── 🗑️ Legacy files (can be removed)
    ├── main.js
    ├── preload.js
    ├── scraper.js
    ├── injector.js
    └── w1.html
```

## Statistics

- **TypeScript files**: 21
- **Sources**: 2 (LinkedIn, Calendly)
- **Scenarios**: 3 (LinkedIn Chat, LinkedIn Feed, Calendly Confirmation)
- **Readers**: 3
- **Writers**: 1
- **Processors**: 2
- **Documentation files**: 6

## Key Directories

### `/src/types/`
Type definitions for the entire application. All other files import types from here.

### `/src/core/`
Core business logic that's source-agnostic. These modules are stable and rarely need changes.

### `/src/sources/`
**This is where you'll spend most of your time**. Each source is completely independent.

### `/src/processors/`
Post-processing logic. Processors can work with data from any source.

### `/src/ui/`
W2 control panel interface. Single-page application with Tailwind CSS.

## Adding New Components

### To add a new Source:
1. Create folder: `src/sources/YOUR_SOURCE/`
2. Create `source.ts`
3. Create scenarios in `scenarios/`
4. Register in `src/sources/index.ts`

### To add a new Scenario:
1. Create folder: `src/sources/SOURCE/scenarios/YOUR_SCENARIO/`
2. Create `index.ts`
3. Create readers/writers
4. Add to source's scenarios array

### To add a new Reader/Writer:
1. Create file: `src/sources/SOURCE/scenarios/SCENARIO/readers/YOUR_READER.ts`
2. Export Reader/Writer object
3. Add to scenario's array

### To add a new Processor:
1. Create file: `src/processors/YOUR_PROCESSOR.ts`
2. Implement `execute()` function
3. Register in `src/processors/index.ts`

## Build Process

```
TypeScript (.ts) → Compiler (tsc) → JavaScript (.js in dist/)
                                   ↓
                            HTML files copied
                                   ↓
                            electron . (runs main.js)
```

## Data Flow

```
W1 (Browser) ←─────IPC─────→ Main Process ←─────IPC─────→ W2 (Control)
     ↑                            ↑
     │                            │
User navigates              Core Modules
                           (source-manager,
                            scenario-detector,
                            action-executor,
                            data-store)
```

## Security Layers

1. **Context Isolation**: Renderer processes can't access Node.js
2. **Preload Bridge**: Only whitelisted IPC methods exposed
3. **Script Execution**: Scripts run in web context only, no system access

## Module Dependencies

```
main.ts
  ├─→ core/source-manager.ts
  ├─→ core/scenario-detector.ts
  ├─→ core/action-executor.ts
  ├─→ core/data-store.ts
  ├─→ sources/index.ts
  │     ├─→ sources/linkedin/source.ts
  │     │     └─→ scenarios/chat/index.ts
  │     │           ├─→ readers/extract-conversation.ts
  │     │           └─→ writers/inject-message.ts
  │     └─→ sources/calendly/source.ts
  └─→ processors/index.ts
        ├─→ processors/summarize.ts
        └─→ processors/export-json.ts
```

## File Naming Conventions

- **Sources**: `source.ts` (definition)
- **Scenarios**: `index.ts` (in scenario folder)
- **Readers**: `extract-*.ts` or descriptive name
- **Writers**: `inject-*.ts` or descriptive name
- **Processors**: `*.ts` (descriptive name)
- **Test fixtures**: `*.html` (descriptive name)

## Import Paths

Examples of typical imports:

```typescript
// From a reader to types
import { Reader } from '../../../../../types';

// From a scenario to reader
import { extractData } from './readers/extract-data';

// From a source to scenario
import { chatScenario } from './scenarios/chat';

// From sources registry to source
import { linkedinSource } from './linkedin/source';

// From main to core
import { SourceManager } from './core/source-manager';
```

## Configuration Files

### `tsconfig.json`
- Target: ES2020
- Module: CommonJS
- Strict mode enabled
- Output: `dist/`

### `package.json`
- Main: `dist/main.js`
- Scripts: build, start, dev, watch
- Dependencies: Electron, TypeScript, @types/node

## Development Workflow

1. Make changes in `src/`
2. Run `npm run build`
3. Run `npm start` or `npm run dev`
4. Test in W1 and W2
5. Check console for errors
6. Iterate

For faster iteration, use `npm run watch` in a separate terminal.

## Deployment

To package the app for distribution:

1. Install electron-builder: `npm install --save-dev electron-builder`
2. Add build config to package.json
3. Run: `npm run build && electron-builder`
4. Distribute the generated binary

## Notes

- All source code is in TypeScript
- Compiled output goes to `dist/`
- Legacy JS files (main.js, preload.js, etc.) can be deleted
- HTML files need to be manually copied during build
- Test fixtures are for development only, not included in distribution

