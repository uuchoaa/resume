# LinkedIn Scraper - Electron App

Electron application with two windows:
- **W1**: LinkedIn navigation window (will navigate to LinkedIn)
- **W2**: Control panel (will load Rails app from localhost:3000)

## Setup

```bash
npm install
```

## Run

```bash
npm start
```

## Development

```bash
npm run dev
```

## Architecture

```
┌─────────────────┐      ┌─────────────────┐
│   W1 (LinkedIn) │      │  W2 (Control)   │
│                 │      │                 │
│  Navigation     │◄────►│  Rails App      │
│  Scraping       │      │  localhost:3000 │
└─────────────────┘      └─────────────────┘
         │                        │
         └────────────┬───────────┘
                      │
              ┌───────▼────────┐
              │  Main Process  │
              │  (IPC Bridge)  │
              └────────────────┘
```

## Next Steps

1. ✅ Basic Electron setup with two windows
2. ⏳ Connect W1 to LinkedIn
3. ⏳ Connect W2 to localhost:3000
4. ⏳ Implement IPC communication
5. ⏳ Add scraping functionality
6. ⏳ Integrate with Rails backend

