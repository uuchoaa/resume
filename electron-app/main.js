const { app, BrowserWindow } = require('electron');
const path = require('path');

let linkedinWindow;   // W1
let controlWindow;    // W2

function createWindows() {
  // W1 - LinkedIn Window (será usado para navegação)
  linkedinWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    x: 0,
    y: 0,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    },
    title: 'LinkedIn - W1'
  });

  // Por enquanto carrega HTML estático
  linkedinWindow.loadFile('w1.html');
  linkedinWindow.webContents.openDevTools();

  // W2 - Control Panel (Rails App)
  controlWindow = new BrowserWindow({
    width: 1000,
    height: 600,
    x: 1220,
    y: 0,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    },
    title: 'Control Panel - W2'
  });

  // Por enquanto carrega HTML estático
  controlWindow.loadFile('w2.html');
  controlWindow.webContents.openDevTools();

  // Handlers para quando as janelas fecham
  linkedinWindow.on('closed', () => {
    linkedinWindow = null;
  });

  controlWindow.on('closed', () => {
    controlWindow = null;
  });
}

// Quando o Electron estiver pronto
app.whenReady().then(() => {
  createWindows();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindows();
    }
  });
});

// Quit quando todas as janelas forem fechadas (exceto no macOS)
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

