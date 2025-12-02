# Examples

This file contains practical examples for extending the application.

## Example 1: Adding Calendly as a Second Source

We've already implemented Calendly as an example. Here's what was done:

### Files Created

```
src/sources/calendly/
├── source.ts                                    # Source definition
└── scenarios/
    └── confirmation/
        ├── index.ts                             # Scenario definition
        ├── readers/
        │   └── extract-booking.ts               # Reader implementation
        └── test-fixtures/
            └── confirmation.html                # Test HTML
```

### 1. Source Definition (`calendly/source.ts`)

```typescript
import { Source } from '../../types';
import { calendlyConfirmationScenario } from './scenarios/confirmation';

export const calendlySource: Source = {
  id: 'calendly',
  name: 'Calendly',
  domains: ['calendly.com'],
  scenarios: [calendlyConfirmationScenario]
};
```

### 2. Scenario Definition (`scenarios/confirmation/index.ts`)

```typescript
import { Scenario } from '../../../../types';
import { extractBooking } from './readers/extract-booking';

export const calendlyConfirmationScenario: Scenario = {
  id: 'calendly-confirmation',
  name: 'Calendly Confirmation',
  urlPattern: /calendly\.com\/[^/]+\/[^/]+\/(confirmed|scheduled)/,
  readers: [extractBooking],
  writers: []
};
```

### 3. Reader Implementation

The reader extracts:
- Meeting title
- Date and time
- Organizer info
- Location/meeting link
- Invitee details
- Notes

### 4. Registration

Added to `src/sources/index.ts`:

```typescript
import { calendlySource } from './calendly/source';

export const allSources: Source[] = [
  linkedinSource,
  calendlySource  // ← Added here
];
```

**That's it!** Calendly is now available. Navigate to a Calendly confirmation page in W1 and the reader will appear in W2.

---

## Example 2: Adding a Custom Processor

Let's create a processor that sends data to a webhook.

### Create the Processor

`src/processors/send-to-webhook.ts`:

```typescript
import { Processor } from '../types';
import https from 'https';

export const sendToWebhookProcessor: Processor = {
  id: 'send-to-webhook',
  name: 'Send to Webhook',
  description: 'Sends extracted data to a configured webhook URL',
  
  async execute(data: any): Promise<any> {
    const webhookUrl = process.env.WEBHOOK_URL || 'https://webhook.site/your-unique-url';
    
    return new Promise((resolve, reject) => {
      const url = new URL(webhookUrl);
      const postData = JSON.stringify(data);
      
      const options = {
        hostname: url.hostname,
        port: url.port || 443,
        path: url.pathname,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData)
        }
      };
      
      const req = https.request(options, (res) => {
        let responseData = '';
        
        res.on('data', (chunk) => {
          responseData += chunk;
        });
        
        res.on('end', () => {
          resolve({
            success: true,
            message: 'Data sent to webhook',
            statusCode: res.statusCode,
            response: responseData
          });
        });
      });
      
      req.on('error', (error) => {
        resolve({
          success: false,
          error: error.message
        });
      });
      
      req.write(postData);
      req.end();
    });
  }
};
```

### Register the Processor

`src/processors/index.ts`:

```typescript
import { sendToWebhookProcessor } from './send-to-webhook';

export const allProcessors: Processor[] = [
  summarizeProcessor,
  exportJsonProcessor,
  sendToWebhookProcessor  // ← Added here
];
```

---

## Example 3: Multiple Scenarios for One Source

Let's add a "Profile" scenario to LinkedIn.

### Create the Scenario

`src/sources/linkedin/scenarios/profile/readers/extract-profile.ts`:

```typescript
import { Reader } from '../../../../../types';

export const extractProfile: Reader = {
  id: 'extract-profile',
  name: 'Extract Profile',
  description: 'Extracts user profile information',
  script: `
(async () => {
  try {
    const name = document.querySelector('.text-heading-xlarge')?.textContent?.trim();
    const headline = document.querySelector('.text-body-medium')?.textContent?.trim();
    const location = document.querySelector('.text-body-small.inline')?.textContent?.trim();
    
    // Extract experience
    const experience = Array.from(document.querySelectorAll('#experience ~ * li')).map(el => ({
      title: el.querySelector('.t-bold')?.textContent?.trim(),
      company: el.querySelector('.t-14.t-normal')?.textContent?.trim(),
      duration: el.querySelector('.t-14.t-normal.t-black--light')?.textContent?.trim()
    }));
    
    return {
      success: true,
      profile: {
        name,
        headline,
        location,
        experience
      },
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

### Create Scenario Index

`src/sources/linkedin/scenarios/profile/index.ts`:

```typescript
import { Scenario } from '../../../../types';
import { extractProfile } from './readers/extract-profile';

export const linkedinProfileScenario: Scenario = {
  id: 'linkedin-profile',
  name: 'LinkedIn Profile',
  urlPattern: /linkedin\.com\/in\/[^/]+/,
  readers: [extractProfile],
  writers: []
};
```

### Add to LinkedIn Source

`src/sources/linkedin/source.ts`:

```typescript
import { linkedinChatScenario } from './scenarios/chat';
import { linkedinFeedScenario } from './scenarios/feed';
import { linkedinProfileScenario } from './scenarios/profile';  // ← Add import

export const linkedinSource: Source = {
  id: 'linkedin',
  name: 'LinkedIn',
  domains: ['linkedin.com', 'www.linkedin.com'],
  scenarios: [
    linkedinChatScenario,
    linkedinFeedScenario,
    linkedinProfileScenario  // ← Add here
  ]
};
```

---

## Example 4: Writer with Complex Input

Let's create a writer that fills out a form.

### Create the Writer

`src/sources/example/scenarios/contact-form/writers/fill-form.ts`:

```typescript
import { Writer } from '../../../../../types';

export const fillContactForm: Writer = {
  id: 'fill-contact-form',
  name: 'Fill Contact Form',
  description: 'Automatically fills out a contact form',
  script: `
(async () => {
  try {
    // __INPUT_DATA__ should be an object like:
    // { name: "John", email: "john@example.com", message: "Hello" }
    
    const data = __INPUT_DATA__;
    
    // Fill name field
    const nameField = document.querySelector('input[name="name"], #name');
    if (nameField) {
      nameField.value = data.name || '';
      nameField.dispatchEvent(new Event('input', { bubbles: true }));
    }
    
    // Fill email field
    const emailField = document.querySelector('input[name="email"], #email');
    if (emailField) {
      emailField.value = data.email || '';
      emailField.dispatchEvent(new Event('input', { bubbles: true }));
    }
    
    // Fill message field
    const messageField = document.querySelector('textarea[name="message"], #message');
    if (messageField) {
      messageField.value = data.message || '';
      messageField.dispatchEvent(new Event('input', { bubbles: true }));
    }
    
    return {
      success: true,
      message: 'Form filled successfully',
      fields: {
        name: !!nameField,
        email: !!emailField,
        message: !!messageField
      }
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

**Usage in W2**: When you click this writer, enter JSON in the modal:

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "message": "I'd like to discuss a project."
}
```

---

## Example 5: Processor with File Export

Let's create a processor that exports to CSV.

### Create the Processor

`src/processors/export-csv.ts`:

```typescript
import { Processor } from '../types';
import * as fs from 'fs';
import * as path from 'path';
import { app } from 'electron';

export const exportCsvProcessor: Processor = {
  id: 'export-csv',
  name: 'Export CSV',
  description: 'Exports data as a CSV file',
  
  async execute(data: any): Promise<any> {
    try {
      // Convert data to CSV
      let csv = '';
      
      // If it's LinkedIn chat data
      if (data.messages && Array.isArray(data.messages)) {
        // Headers
        csv = 'Index,Sender,Text,Time,Date\n';
        
        // Rows
        data.messages.forEach((msg: any) => {
          const row = [
            msg.index,
            msg.sender,
            `"${msg.text.replace(/"/g, '""')}"`,  // Escape quotes
            msg.time,
            msg.conversationDate || ''
          ].join(',');
          csv += row + '\n';
        });
      } else {
        // Generic CSV export
        const keys = Object.keys(data);
        csv = keys.join(',') + '\n';
        csv += keys.map(k => JSON.stringify(data[k])).join(',') + '\n';
      }
      
      // Save to file
      const exportDir = path.join(app.getPath('userData'), 'exports');
      if (!fs.existsSync(exportDir)) {
        fs.mkdirSync(exportDir, { recursive: true });
      }
      
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const filename = `export-${timestamp}.csv`;
      const filepath = path.join(exportDir, filename);
      
      fs.writeFileSync(filepath, csv, 'utf-8');
      
      return {
        success: true,
        message: 'CSV exported successfully',
        filepath,
        filename,
        rows: csv.split('\n').length - 1
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

---

## Example 6: Testing with Local HTML

### Step-by-Step Testing Workflow

1. **Navigate to the target page** in W1
2. **Save the HTML**:
   - Right-click → "Save Page As"
   - Choose "Webpage, Complete"
   - Save to desktop temporarily

3. **Copy to test fixtures**:
   ```bash
   cp ~/Desktop/page.html src/sources/YOUR_SOURCE/scenarios/SCENARIO/test-fixtures/test.html
   ```

4. **Test your script**:
   - Open `test.html` in a regular browser
   - Open DevTools console
   - Paste your script
   - Run and refine

5. **Update your reader/writer**:
   ```typescript
   export const yourReader: Reader = {
     id: 'your-reader',
     name: 'Your Reader',
     description: 'Description',
     testFixture: 'test.html',  // ← Reference the fixture
     script: `/* your tested script */`
   };
   ```

6. **Build and test in app**:
   ```bash
   npm run build
   npm start
   ```

---

## Example 7: URL Pattern Matching

### Common Patterns

```typescript
// Exact path
urlPattern: /example\.com\/contact$/

// With trailing slash optional
urlPattern: /example\.com\/contact\/?$/

// With parameters
urlPattern: /example\.com\/user\/\d+/

// Multiple paths
urlPattern: /example\.com\/(about|contact|support)/

// With query params (ignore them)
urlPattern: /example\.com\/search/

// Match subdomain
urlPattern: /app\.example\.com/

// Match any subdomain
urlPattern: /[a-z]+\.example\.com/

// Calendly-style (username + event)
urlPattern: /calendly\.com\/[^/]+\/[^/]+/
```

### Testing Patterns

Test your regex in the browser console:

```javascript
const pattern = /linkedin\.com\/messaging/;
pattern.test(window.location.href);  // true or false
```

---

## Example 8: Handling Dynamic Content

### Waiting for Elements

```javascript
(async () => {
  // Wait for element to appear
  const waitForElement = (selector, timeout = 5000) => {
    return new Promise((resolve, reject) => {
      const startTime = Date.now();
      
      const check = () => {
        const element = document.querySelector(selector);
        if (element) {
          resolve(element);
        } else if (Date.now() - startTime > timeout) {
          reject(new Error('Element not found: ' + selector));
        } else {
          setTimeout(check, 100);
        }
      };
      
      check();
    });
  };
  
  try {
    const element = await waitForElement('.dynamic-content');
    const data = element.textContent;
    
    return { success: true, data };
  } catch (error) {
    return { success: false, error: error.message };
  }
})();
```

### Scrolling to Load More

```javascript
(async () => {
  const scrollToBottom = () => {
    window.scrollTo(0, document.body.scrollHeight);
  };
  
  // Scroll and wait multiple times
  for (let i = 0; i < 5; i++) {
    scrollToBottom();
    await new Promise(r => setTimeout(r, 1000));
  }
  
  // Now extract data
  const items = document.querySelectorAll('.item');
  // ... extract
})();
```

---

## Summary

These examples demonstrate:
- ✅ Adding new sources (Calendly)
- ✅ Creating custom processors (Webhook, CSV)
- ✅ Multiple scenarios per source
- ✅ Complex writers with structured input
- ✅ Testing workflow with local HTML
- ✅ URL pattern matching strategies
- ✅ Handling dynamic content

All examples follow the same modular pattern and require no modifications to the core system.

