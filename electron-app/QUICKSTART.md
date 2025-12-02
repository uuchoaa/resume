# Quick Start Guide

## Installation & Setup

```bash
cd electron-app
npm install
npm run build
npm start
```

## Testing the Application

### 1. Basic Usage

When you run the app, two windows will open:

- **W1 (Left)**: Browser window - Navigate to LinkedIn and log in
- **W2 (Right)**: Control panel - Shows available actions and data history

### 2. Test LinkedIn Chat Extraction

1. In W1, navigate to https://www.linkedin.com/messaging/
2. Log in to your LinkedIn account
3. Open any conversation
4. In W2, you should see "LinkedIn Chat" detected
5. Click "Extract Conversation" button
6. Check W2's "Data History" section for extracted data
7. Click on a history item to view details
8. Apply a processor like "Summarize" or "Export JSON"

### 3. Test LinkedIn Chat Injection

1. While viewing a LinkedIn chat in W1
2. In W2, click "Inject Message" button
3. Enter your message text in the modal
4. Click "Execute"
5. Check W1 - the text should appear in the message box

## Creating Your First Custom Scraper

Let's create a simple scraper for a new source:

### Step 1: Get the HTML

1. Navigate to the page you want to scrape in W1
2. Right-click → "Inspect" → Copy the HTML you need
3. Or use "Save Page As" → "Webpage, Complete"

### Step 2: Create the Source Structure

```bash
mkdir -p src/sources/example/scenarios/page/readers
mkdir -p src/sources/example/scenarios/page/test-fixtures
```

### Step 3: Create the Reader

Create `src/sources/example/scenarios/page/readers/extract-data.ts`:

```typescript
import { Reader } from '../../../../../types';

export const extractData: Reader = {
  id: 'extract-data',
  name: 'Extract Data',
  description: 'Extracts title and content from the page',
  script: `
(async () => {
  try {
    const title = document.querySelector('h1')?.textContent?.trim();
    const content = document.querySelector('.main-content')?.textContent?.trim();
    
    return {
      success: true,
      title: title,
      content: content,
      url: window.location.href,
      timestamp: new Date().toISOString()
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

### Step 4: Create the Scenario

Create `src/sources/example/scenarios/page/index.ts`:

```typescript
import { Scenario } from '../../../../types';
import { extractData } from './readers/extract-data';

export const examplePageScenario: Scenario = {
  id: 'example-page',
  name: 'Example Page',
  urlPattern: /example\.com\/page/,
  readers: [extractData],
  writers: []
};
```

### Step 5: Create the Source

Create `src/sources/example/source.ts`:

```typescript
import { Source } from '../../types';
import { examplePageScenario } from './scenarios/page';

export const exampleSource: Source = {
  id: 'example',
  name: 'Example',
  domains: ['example.com'],
  scenarios: [examplePageScenario]
};
```

### Step 6: Register the Source

Edit `src/sources/index.ts`:

```typescript
import { linkedinSource } from './linkedin/source';
import { exampleSource } from './example/source';  // Add this

export const allSources: Source[] = [
  linkedinSource,
  exampleSource  // Add this
];
```

### Step 7: Build and Test

```bash
npm run build
npm start
```

Navigate to `example.com/page` in W1, and your new reader should appear in W2!

## Testing with Local HTML

To test your scraper without accessing the real website:

1. Save your HTML to `src/sources/example/scenarios/page/test-fixtures/test.html`
2. Create a test window that loads this file
3. Test your scraper script interactively in the browser console
4. Once working, copy the script to your reader definition

**Pro Tip**: Open DevTools in W1, paste your script in the console, run it, refine it, then copy to your `.ts` file.

## Debugging Tips

### Script Not Working?

1. Open DevTools in W1 (it should be open by default)
2. Look for console errors when the script executes
3. Add `console.log()` statements in your script
4. Test the selectors manually: `document.querySelector('.your-selector')`

### Scenario Not Detected?

1. Check your URL pattern regex
2. Test it: `/example\.com/.test(window.location.href)` in console
3. Make sure domains are correct in your source definition

### Data Not Showing in W2?

1. Check the console in W2 for IPC errors
2. Make sure your script returns an object
3. Check that `success: true` is in the returned object

## Next Steps

- Read the full [README.md](README.md) for detailed architecture
- Explore existing sources in `src/sources/`
- Create processors in `src/processors/`
- Join our community (if applicable)

## Common Patterns

### Extract List Items

```javascript
const items = Array.from(document.querySelectorAll('.item')).map(el => ({
  title: el.querySelector('.title')?.textContent?.trim(),
  price: el.querySelector('.price')?.textContent?.trim()
}));
```

### Wait for Element

```javascript
await new Promise(resolve => {
  const check = () => {
    if (document.querySelector('.loaded')) resolve();
    else setTimeout(check, 100);
  };
  check();
});
```

### Click and Wait

```javascript
document.querySelector('.button')?.click();
await new Promise(r => setTimeout(r, 1000));
```

Happy scraping! 🚀

