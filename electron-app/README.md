# Electron Scraper - Modular Architecture

A modular TypeScript-based Electron application for web scraping with extensible sources, scenarios, and actions.

## Overview

This application provides a framework for extracting and injecting data from/to websites through a clean, modular architecture.

### Core Concepts

- **Source**: A website or platform (e.g., LinkedIn, Calendly)
- **Scenario**: A specific context within a source, detected by URL pattern (e.g., LinkedIn Chat, LinkedIn Feed)
- **Reader**: An action that extracts data from a page (read operation)
- **Writer**: An action that injects data into a page (write operation)
- **Processor**: Post-processing of extracted data (summarize, export, etc.)

### Windows

- **W1 (Browser)**: A full browser window where you navigate freely. The app automatically detects the source and scenario based on the current URL.
- **W2 (Control Panel)**: Shows available actions for the current scenario, displays extraction history, and allows applying processors to data.

## Architecture

```
electron-app/
  src/
    main.ts              # Main process (manages windows, IPC)
    preload.ts           # IPC bridge
    types/
      index.ts           # TypeScript interfaces
    
    sources/             # All sources live here
      index.ts           # Sources registry
      linkedin/
        source.ts        # LinkedIn source definition
        scenarios/
          chat/
            readers/
              extract-conversation.ts
            writers/
              inject-message.ts
            test-fixtures/
              chat.html  # Test HTML for development
    
    processors/          # Data processors
      index.ts           # Processors registry
      summarize.ts
      export-json.ts
    
    core/                # Core functionality
      source-manager.ts
      scenario-detector.ts
      action-executor.ts
      data-store.ts
    
    ui/
      w2.html           # Control panel UI
      w2.ts             # Control panel logic
```

## Getting Started

### Installation

```bash
cd electron-app
npm install
```

### Running

```bash
npm start
```

For development with logging:

```bash
npm run dev
```

### Building

```bash
npm run build
```

## Adding New Components

### Adding a New Source

1. Create a folder: `src/sources/YOUR_SOURCE/`
2. Create `source.ts`:

```typescript
import { Source } from '../../types';
import { yourScenario } from './scenarios/your-scenario';

export const yourSource: Source = {
  id: 'your-source',
  name: 'Your Source',
  domains: ['example.com', 'www.example.com'],
  scenarios: [yourScenario]
};
```

3. Register in `src/sources/index.ts`:

```typescript
import { yourSource } from './your-source/source';

export const allSources: Source[] = [
  linkedinSource,
  yourSource  // Add here
];
```

### Adding a New Scenario

1. Create a folder: `src/sources/YOUR_SOURCE/scenarios/your-scenario/`
2. Create `index.ts`:

```typescript
import { Scenario } from '../../../../types';
import { yourReader } from './readers/your-reader';
import { yourWriter } from './writers/your-writer';

export const yourScenario: Scenario = {
  id: 'your-source-scenario',
  name: 'Your Scenario Name',
  urlPattern: /example\.com\/your-page/,  // Regex to match URLs
  readers: [yourReader],
  writers: [yourWriter]
};
```

3. Add to your source's scenarios array in `source.ts`

### Adding a Reader (Extract Data)

1. Create: `src/sources/YOUR_SOURCE/scenarios/SCENARIO/readers/your-reader.ts`

```typescript
import { Reader } from '../../../../../types';

export const yourReader: Reader = {
  id: 'your-reader',
  name: 'Your Reader Name',
  description: 'What this reader does',
  testFixture: 'test.html',  // Optional
  script: `
(async () => {
  try {
    // Your extraction logic here
    const data = {
      title: document.querySelector('h1')?.textContent,
      // ... more extraction
    };
    
    return {
      success: true,
      data: data
    };
  } catch (error) {
    return {
      success: false,
      error: error.message
    };
  }
})();
  `.trim()
};
```

**Important**: The script is injected and executed in the browser context, so:
- Use vanilla JavaScript (no Node.js APIs)
- Return a result object with `success` boolean
- Handle errors gracefully

### Adding a Writer (Inject Data)

1. Create: `src/sources/YOUR_SOURCE/scenarios/SCENARIO/writers/your-writer.ts`

```typescript
import { Writer } from '../../../../../types';

export const yourWriter: Writer = {
  id: 'your-writer',
  name: 'Your Writer Name',
  description: 'What this writer does',
  testFixture: 'test.html',  // Optional
  script: `
(async () => {
  try {
    // __INPUT_DATA__ is automatically injected by the executor
    const inputText = typeof __INPUT_DATA__ === 'string' ? __INPUT_DATA__ : __INPUT_DATA__?.text;
    
    const textarea = document.querySelector('textarea.my-input');
    if (!textarea) {
      return { success: false, error: 'Textarea not found' };
    }
    
    textarea.value = inputText;
    textarea.dispatchEvent(new Event('input', { bubbles: true }));
    
    return {
      success: true,
      message: 'Text injected'
    };
  } catch (error) {
    return {
      success: false,
      error: error.message
    };
  }
})();
  `.trim()
};
```

### Adding a Processor

1. Create: `src/processors/your-processor.ts`

```typescript
import { Processor } from '../types';

export const yourProcessor: Processor = {
  id: 'your-processor',
  name: 'Your Processor',
  description: 'What this processor does',
  
  async execute(data: any): Promise<any> {
    try {
      // Process the data
      const processed = {
        // Your processing logic
      };
      
      return {
        success: true,
        result: processed
      };
    } catch (error: any) {
      return {
        success: false,
        error: error.message
      };
    }
  }
};
```

2. Register in `src/processors/index.ts`:

```typescript
import { yourProcessor } from './your-processor';

export const allProcessors: Processor[] = [
  summarizeProcessor,
  exportJsonProcessor,
  yourProcessor  // Add here
];
```

## Testing Scrapers with Local HTML

To develop and test scrapers without needing the actual website:

1. Navigate to the target page in W1
2. Save the page HTML (right-click → Save As → "Webpage, Complete")
3. Place the HTML file in: `src/sources/YOUR_SOURCE/scenarios/SCENARIO/test-fixtures/`
4. Set `testFixture` in your reader/writer definition
5. Create a test scenario that loads the local HTML
6. Test your scraper script against the local file

**Workflow**:
- Copy HTML from real page
- Paste into `test-fixtures/your-test.html`
- Write/refine your scraper script
- Test locally first, then on real page

## Development Tips

### Rebuilding After Changes

```bash
npm run build
npm start
```

Or use watch mode in a separate terminal:

```bash
npm run watch
```

### Debugging

- Both W1 and W2 have DevTools open by default
- Check console in W2 for IPC communication
- Check console in W1 for injected script execution
- Use `console.log()` in your scripts for debugging

### URL Pattern Matching

Scenarios are matched by regex patterns. Examples:

```typescript
// Match exact path
urlPattern: /linkedin\.com\/messaging/

// Match with parameters
urlPattern: /calendly\.com\/[^/]+\/confirmed/

// Match multiple paths
urlPattern: /linkedin\.com\/(feed|jobs|groups)/
```

## Current Sources & Scenarios

### LinkedIn

- **Chat Scenario** (`linkedin.com/messaging`)
  - Reader: Extract Conversation - Extracts all messages and contact info
  - Writer: Inject Message - Injects text into the message box

- **Feed Scenario** (`linkedin.com/feed`)
  - Reader: Extract Posts - Placeholder for future implementation

## Data Flow

1. User navigates in W1 → URL changes
2. Main process detects source & scenario
3. W2 displays available readers/writers
4. User clicks reader → Script injected into W1 → Data extracted
5. Data stored in temp DataStore
6. W2 displays data in history
7. User selects data + processor → Processor executes
8. Processed data attached to original record

## Architecture Benefits

✅ **Modular**: Each source/scenario/action is independent  
✅ **Extensible**: Add new components without modifying core  
✅ **Testable**: Test scrapers with local HTML files  
✅ **Type-Safe**: TypeScript for better development experience  
✅ **Organized**: Clear folder structure, easy to navigate  

## Future Enhancements

- [ ] Persist data to SQLite instead of memory-only
- [ ] Scheduling/automation of actions
- [ ] Chrome extension mode
- [ ] More processors (AI summarization, cloud sync, etc.)
- [ ] Import/export source definitions
- [ ] Visual scraper builder (no-code)

## License

MIT
