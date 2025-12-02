/**
 * Main Electron Process
 * Manages W1 (browser window) and W2 (control panel)
 */

import { app, BrowserWindow, ipcMain, clipboard } from 'electron';
import * as path from 'path';
import * as fs from 'fs';
import * as os from 'os';
import { SourceManager } from './core/source-manager';
import { ScenarioDetector } from './core/scenario-detector';
import { ActionExecutor } from './core/action-executor';
import { DataStore } from './core/data-store';
import { allSources } from './sources';
import { allProcessors } from './processors';

let w1: BrowserWindow | null = null;  // Browser window
let w2: BrowserWindow | null = null;  // Control panel

// Initialize core modules
const sourceManager = new SourceManager();
const scenarioDetector = new ScenarioDetector();
const actionExecutor = new ActionExecutor();
const dataStore = new DataStore();

// Register all sources
allSources.forEach(source => sourceManager.register(source));

function createWindows() {
  // W1 - Browser Window with navigation bar
  w1 = new BrowserWindow({
    width: 1200,
    height: 800,
    x: 0,
    y: 0,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
      partition: 'persist:browsing'
    },
    title: 'Browser - W1'
  });

  // Load initial URL (LinkedIn messaging)
  // w1.loadURL('https://www.linkedin.com/messaging/');
  w1.loadURL('https://bloco-de-pedra.web.app/lancar-presenca');
  // w1.webContents.openDevTools();

  // Listen to navigation changes in W1
  w1.webContents.on('did-navigate', () => {
    notifyW2OfUrlChange();
  });

  w1.webContents.on('did-navigate-in-page', () => {
    notifyW2OfUrlChange();
  });

  // W2 - Control Panel
  w2 = new BrowserWindow({
    width: 1000,
    height: 800,
    x: 1220,
    y: 0,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    },
    title: 'Control Panel - W2'
  });

  // Load W2 UI (React app)
  w2.loadFile(path.join(__dirname, 'ui/index.html'));
  w2.webContents.openDevTools();

  // Handle window close
  w1.on('closed', () => {
    w1 = null;
  });

  w2.on('closed', () => {
    w2 = null;
  });
}

/**
 * Notify W2 when W1 URL changes
 */
function notifyW2OfUrlChange() {
  if (!w1 || !w2) return;

  const url = w1.webContents.getURL();
  const hostname = new URL(url).hostname;

  // Find source by domain
  const source = sourceManager.findSourceByDomain(hostname);

  if (source) {
    // Detect scenario
    const scenario = scenarioDetector.detect(source, url);

    w2.webContents.send('url-changed', {
      url,
      source: {
        id: source.id,
        name: source.name
      },
      scenario: scenario ? {
        id: scenario.id,
        name: scenario.name,
        readers: scenario.readers.map(r => ({ id: r.id, name: r.name, description: r.description })),
        writers: scenario.writers.map(w => ({ id: w.id, name: w.name, description: w.description }))
      } : null
    });
  } else {
    w2.webContents.send('url-changed', {
      url,
      source: null,
      scenario: null
    });
  }
}

// App lifecycle
app.whenReady().then(() => {
  createWindows();
  
  // Send initial data to W2 after it loads
  setTimeout(() => {
    if (w2) {
      w2.webContents.send('init-data', {
        sources: sourceManager.getAllSources().map(s => ({
          id: s.id,
          name: s.name,
          domains: s.domains
        })),
        processors: allProcessors.map(p => ({
          id: p.id,
          name: p.name,
          description: p.description
        }))
      });
      notifyW2OfUrlChange();
    }
  }, 1000);

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindows();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// ========================================
// IPC Handlers
// ========================================

/**
 * Get current URL from W1
 */
ipcMain.handle('get-current-url', async () => {
  if (!w1) return null;
  return w1.webContents.getURL();
});

/**
 * Navigate W1 to a URL
 */
ipcMain.handle('navigate-to', async (event, url: string) => {
  if (!w1) return { success: false, error: 'W1 not available' };
  
  try {
    await w1.loadURL(url);
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
});

/**
 * Navigate W1 back
 */
ipcMain.handle('navigate-back', async () => {
  if (!w1 || !w1.webContents.canGoBack()) return { success: false };
  w1.webContents.goBack();
  return { success: true };
});

/**
 * Navigate W1 forward
 */
ipcMain.handle('navigate-forward', async () => {
  if (!w1 || !w1.webContents.canGoForward()) return { success: false };
  w1.webContents.goForward();
  return { success: true };
});

/**
 * Reload W1
 */
ipcMain.handle('reload', async () => {
  if (!w1) return { success: false };
  w1.webContents.reload();
  return { success: true };
});

/**
 * Execute a reader
 */
ipcMain.handle('execute-reader', async (event, sourceId: string, scenarioId: string, readerId: string) => {
  if (!w1) return { success: false, error: 'W1 not available' };

  const source = sourceManager.getSource(sourceId);
  if (!source) return { success: false, error: 'Source not found' };

  const scenario = scenarioDetector.findScenarioById(source, scenarioId);
  if (!scenario) return { success: false, error: 'Scenario not found' };

  const reader = scenario.readers.find(r => r.id === readerId);
  if (!reader) return { success: false, error: 'Reader not found' };

  const result = await actionExecutor.executeReader(w1, reader, sourceId, scenarioId);
  
  // Store result
  const recordId = dataStore.add(result);

  // Notify W2
  if (w2) {
    w2.webContents.send('data-updated', dataStore.getAll());
  }

  return { ...result, recordId };
});

/**
 * Execute a writer
 */
ipcMain.handle('execute-writer', async (event, sourceId: string, scenarioId: string, writerId: string, inputData: any) => {
  if (!w1) return { success: false, error: 'W1 not available' };

  const source = sourceManager.getSource(sourceId);
  if (!source) return { success: false, error: 'Source not found' };

  const scenario = scenarioDetector.findScenarioById(source, scenarioId);
  if (!scenario) return { success: false, error: 'Scenario not found' };

  const writer = scenario.writers.find(w => w.id === writerId);
  if (!writer) return { success: false, error: 'Writer not found' };

  const result = await actionExecutor.executeWriter(w1, writer, sourceId, scenarioId, inputData);
  
  // Store result
  const recordId = dataStore.add(result);

  // Notify W2
  if (w2) {
    w2.webContents.send('data-updated', dataStore.getAll());
  }

  return { ...result, recordId };
});

/**
 * Get all data records
 */
ipcMain.handle('get-all-records', async () => {
  return dataStore.getAll();
});

/**
 * Execute a processor on a data record
 */
ipcMain.handle('execute-processor', async (event, recordId: string, processorId: string) => {
  const record = dataStore.get(recordId);
  if (!record) return { success: false, error: 'Record not found' };

  const processor = allProcessors.find(p => p.id === processorId);
  if (!processor) return { success: false, error: 'Processor not found' };

  try {
    const output = await processor.execute(record.result.data);
    
    // Update record with processed data
    dataStore.updateProcessed(recordId, processorId, processor.name, output);

    // Notify W2
    if (w2) {
      w2.webContents.send('data-updated', dataStore.getAll());
    }

    return { success: true, output };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
});

/**
 * Clear all data records
 */
ipcMain.handle('clear-records', async () => {
  dataStore.clear();
  
  // Notify W2
  if (w2) {
    w2.webContents.send('data-updated', dataStore.getAll());
  }

  return { success: true };
});

/**
 * Capture W1 page and save to Downloads folder (full page)
 */
ipcMain.handle('capture-and-save-page', async () => {
  if (!w1) return { success: false, error: 'W1 not available' };
  
  try {
    // Use Chrome DevTools Protocol for full page screenshot
    const debug = w1.webContents.debugger;
    
    try {
      // Attach debugger
      await debug.attach('1.3');
      
      // Get layout metrics to determine full page size
      const { contentSize } = await debug.sendCommand('Page.getLayoutMetrics');
      
      // Capture screenshot with full page dimensions
      const { data } = await debug.sendCommand('Page.captureScreenshot', {
        format: 'png',
        captureBeyondViewport: true,
        clip: {
          x: 0,
          y: 0,
          width: contentSize.width,
          height: contentSize.height,
          scale: 1
        }
      });
      
      // Detach debugger
      debug.detach();
      
      // Get Downloads folder
      const downloadsPath = path.join(os.homedir(), 'Downloads');
      const timestamp = new Date().toISOString().replace(/:/g, '-').split('.')[0];
      const fileName = `screenshot-${timestamp}.png`;
      const filePath = path.join(downloadsPath, fileName);
      
      // Save file (data is base64)
      fs.writeFileSync(filePath, Buffer.from(data, 'base64'));
      
      return { success: true, filePath, fileName };
    } catch (debugError: any) {
      // Ensure debugger is detached on error
      try {
        debug.detach();
      } catch (e) {
        // Ignore detach errors
      }
      throw debugError;
    }
  } catch (error: any) {
    return { success: false, error: error.message };
  }
});

/**
 * Capture W1 page and copy to clipboard (full page)
 */
ipcMain.handle('capture-to-clipboard', async () => {
  if (!w1) return { success: false, error: 'W1 not available' };
  
  try {
    // Use Chrome DevTools Protocol for full page screenshot
    const debug = w1.webContents.debugger;
    
    try {
      // Attach debugger
      await debug.attach('1.3');
      
      // Get layout metrics to determine full page size
      const { contentSize } = await debug.sendCommand('Page.getLayoutMetrics');
      
      // Capture screenshot with full page dimensions
      const { data } = await debug.sendCommand('Page.captureScreenshot', {
        format: 'png',
        captureBeyondViewport: true,
        clip: {
          x: 0,
          y: 0,
          width: contentSize.width,
          height: contentSize.height,
          scale: 1
        }
      });
      
      // Detach debugger
      debug.detach();
      
      // Convert base64 to NativeImage and copy to clipboard
      const { nativeImage } = require('electron');
      const image = nativeImage.createFromBuffer(Buffer.from(data, 'base64'));
      clipboard.writeImage(image);
      
      return { success: true };
    } catch (debugError: any) {
      // Ensure debugger is detached on error
      try {
        debug.detach();
      } catch (e) {
        // Ignore detach errors
      }
      throw debugError;
    }
  } catch (error: any) {
    return { success: false, error: error.message };
  }
});

