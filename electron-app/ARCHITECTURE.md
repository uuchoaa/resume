# Architecture Documentation

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Electron App                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐              ┌──────────────────┐    │
│  │   W1 (Browser)   │              │  W2 (Control)    │    │
│  │                  │              │                  │    │
│  │  ┌────────────┐  │              │  ┌────────────┐  │    │
│  │  │  WebView   │  │              │  │ Tailwind   │  │    │
│  │  │ (LinkedIn, │  │◄────IPC─────►│  │    UI      │  │    │
│  │  │ Calendly,  │  │              │  │            │  │    │
│  │  │   etc.)    │  │              │  └────────────┘  │    │
│  │  └────────────┘  │              │                  │    │
│  └──────────────────┘              └──────────────────┘    │
│           │                                 │               │
│           │                                 │               │
│           └────────────┬────────────────────┘               │
│                        │                                    │
│                  ┌─────▼─────┐                             │
│                  │  Main.ts  │                             │
│                  │           │                             │
│                  │  IPC Hub  │                             │
│                  └─────┬─────┘                             │
│                        │                                    │
│         ┌──────────────┼──────────────┐                    │
│         │              │              │                    │
│    ┌────▼────┐   ┌────▼────┐   ┌────▼────┐              │
│    │ Source  │   │Scenario │   │ Action  │              │
│    │ Manager │   │Detector │   │Executor │              │
│    └─────────┘   └─────────┘   └─────────┘              │
│         │              │              │                    │
│         └──────────────┼──────────────┘                    │
│                        │                                    │
│                  ┌─────▼─────┐                             │
│                  │DataStore  │                             │
│                  │(in-memory)│                             │
│                  └───────────┘                             │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Scenario Detection Flow

```
W1 URL Changes
    │
    ▼
Main Process detects URL change
    │
    ▼
SourceManager.findSourceByDomain(hostname)
    │
    ├─ No match → W2 shows "No source detected"
    │
    └─ Match found → ScenarioDetector.detect(source, url)
           │
           ├─ No scenario → W2 shows "No scenario detected"
           │
           └─ Scenario found → W2 displays available Readers & Writers
```

### Reader Execution Flow

```
User clicks Reader in W2
    │
    ▼
IPC: execute-reader(sourceId, scenarioId, readerId)
    │
    ▼
Main Process:
  1. Find Source
  2. Find Scenario
  3. Find Reader
    │
    ▼
ActionExecutor.executeReader(w1, reader, ...)
    │
    ▼
w1.webContents.executeJavaScript(reader.script)
    │
    ▼
Script executes in W1 browser context
    │
    ▼
Data extracted and returned
    │
    ▼
ExecutionResult created
    │
    ▼
DataStore.add(result) → generates recordId
    │
    ▼
IPC: data-updated sent to W2
    │
    ▼
W2 updates History UI
```

### Writer Execution Flow

```
User clicks Writer in W2
    │
    ▼
W2 shows input modal
    │
    ▼
User enters data and submits
    │
    ▼
IPC: execute-writer(sourceId, scenarioId, writerId, inputData)
    │
    ▼
Main Process wraps script with __INPUT_DATA__
    │
    ▼
ActionExecutor.executeWriter(w1, writer, inputData)
    │
    ▼
w1.webContents.executeJavaScript(wrappedScript)
    │
    ▼
Script executes with input data available
    │
    ▼
Result stored and sent to W2
```

### Processor Flow

```
User clicks on record in W2 History
    │
    ▼
W2 shows detail modal with data
    │
    ▼
User selects Processor and clicks Apply
    │
    ▼
IPC: execute-processor(recordId, processorId)
    │
    ▼
Main Process:
  1. Get record from DataStore
  2. Get processor
  3. Execute processor.execute(record.result.data)
    │
    ▼
Processor runs (Node.js context, can do file I/O, API calls, etc.)
    │
    ▼
Processed output returned
    │
    ▼
DataStore.updateProcessed(recordId, processorId, output)
    │
    ▼
IPC: data-updated sent to W2
    │
    ▼
W2 updates detail view
```

## Component Responsibilities

### Main Process (main.ts)

**Responsibilities:**
- Create and manage W1 and W2 windows
- Register all sources and processors
- Handle IPC communication
- Coordinate between Core modules
- Send events to W2 when state changes

**Key Functions:**
- `createWindows()` - Creates W1 and W2
- `notifyW2OfUrlChange()` - Detects and sends scenario info to W2
- IPC Handlers for all actions

### Source Manager

**Responsibilities:**
- Store all registered sources
- Find sources by domain
- Provide source lookup

**Methods:**
- `register(source)` - Register a source
- `getSource(id)` - Get source by ID
- `findSourceByDomain(hostname)` - Match URL to source
- `getAllSources()` - List all sources

### Scenario Detector

**Responsibilities:**
- Match URLs to scenarios using regex patterns
- Provide scenario lookups

**Methods:**
- `detect(source, url)` - Find matching scenario
- `findScenarioById(source, scenarioId)` - Get specific scenario

### Action Executor

**Responsibilities:**
- Inject and execute reader/writer scripts in W1
- Handle script errors
- Format execution results

**Methods:**
- `executeReader(window, reader, sourceId, scenarioId)` - Run reader
- `executeWriter(window, writer, sourceId, scenarioId, inputData)` - Run writer
- `testScript(window, script, htmlPath)` - Test on local HTML

### Data Store

**Responsibilities:**
- Store execution results in memory (session-based)
- Manage processed data associations
- Provide data access

**Methods:**
- `add(result)` - Add new record, returns recordId
- `get(id)` - Get specific record
- `getAll()` - Get all records
- `updateProcessed(id, processorId, output)` - Add processed data
- `clear()` - Clear all records

## Type System

### Source → Scenario → Action Hierarchy

```typescript
Source {
  id: string
  name: string
  domains: string[]
  scenarios: Scenario[]
}
    ↓
Scenario {
  id: string
  name: string
  urlPattern: RegExp
  readers: Reader[]
  writers: Writer[]
}
    ↓
Reader/Writer {
  id: string
  name: string
  description: string
  script: string
  testFixture?: string
}
```

### Execution Results

```typescript
ExecutionResult {
  success: boolean
  data?: any
  error?: string
  timestamp: string
  actionId: string
  actionName: string
  scenarioId: string
  sourceId: string
  url: string
}
    ↓
DataRecord {
  id: string
  result: ExecutionResult
  processed?: {
    processorId: string
    processorName: string
    output: any
    timestamp: string
  }
}
```

## Security Model

### Context Isolation

- **Main Process**: Full Node.js access
- **W1 (Browser)**: No Node.js access, isolated web context
- **W2 (Control)**: Limited API via preload.ts

### Preload Bridge

The `preload.ts` exposes only safe IPC methods to renderer:

```typescript
contextBridge.exposeInMainWorld('electronAPI', {
  // Only whitelisted methods available
  executeReader: (...) => ipcRenderer.invoke(...),
  executeWriter: (...) => ipcRenderer.invoke(...),
  // No direct filesystem, no shell access
});
```

### Script Injection

Scripts are injected via `executeJavaScript()`:
- Run in W1's web context
- Cannot access Node.js APIs
- Cannot access Electron APIs
- Can only interact with the DOM

## Extension Points

### Adding a Source

1. Create source definition
2. Define scenarios with URL patterns
3. Create readers/writers
4. Register in `sources/index.ts`

### Adding a Processor

1. Create processor with `execute()` function
2. Register in `processors/index.ts`
3. Available for all data records

### Adding a Storage Backend

Replace DataStore implementation:
- Current: In-memory Map
- Future: SQLite, IndexedDB, File-based

### Adding Authentication

Extend sources with auth config:
- OAuth flows
- Cookie management
- Session persistence

## Performance Considerations

### Memory

- DataStore keeps all records in memory
- Large extractions can consume significant RAM
- Consider pagination or record limits

### Script Execution

- Scripts run synchronously in W1
- Long-running scripts block the page
- Use `await` and timeouts for async operations

### IPC Overhead

- Each action requires IPC round-trip
- Large data transfers (MB+) may be slow
- Consider chunking large datasets

## Future Improvements

1. **Persistent Storage**: SQLite for data persistence
2. **Background Tasks**: Web Workers for heavy processing
3. **Multi-Window**: Support multiple W1 instances
4. **Plugin System**: Load sources dynamically
5. **Cloud Sync**: Sync data across devices
6. **Scheduling**: Cron-like automation
7. **AI Integration**: LLM-based extraction

