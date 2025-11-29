const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');
const https = require('https');
const http = require('http');

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
      preload: path.join(__dirname, 'preload.js'),
      partition: 'persist:linkedin' // Persiste cookies e sessão
    },
    title: 'LinkedIn - W1'
  });

  // Carrega LinkedIn
  linkedinWindow.loadURL('https://www.linkedin.com/messaging/');
  // linkedinWindow.loadURL(`file://${path.join(__dirname, 'w1.html')}`);
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

  // Carrega Rails app
  controlWindow.loadURL('http://localhost:3000/electron/linkedin');
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

// IPC Handler: W2 solicita scraping de W1
ipcMain.handle('scrape-w1', async () => {
  try {
    console.log('📡 Received scrape request from W2');
    
    // Lê o script de scraping do arquivo
    const scraperScript = fs.readFileSync(
      path.join(__dirname, 'scraper.js'),
      'utf8'
    );
    
    // Injeta script em W1 para fazer o scrape
    const scrapedData = await linkedinWindow.webContents.executeJavaScript(scraperScript);
    
    console.log('✅ Scrape completed:', scrapedData);
    
    // Agora o main process faz o POST para Rails
    if (scrapedData && scrapedData.success) {
      try {
        const apiResponse = await sendToRails(scrapedData);
        console.log('✅ Data sent to Rails:', apiResponse);
        
        return {
          scrapeData: scrapedData,
          apiResponse: apiResponse,
          success: true
        };
      } catch (apiError) {
        console.error('❌ Failed to send to Rails:', apiError);
        return {
          scrapeData: scrapedData,
          apiError: apiError.message,
          success: false
        };
      }
    }
    
    return scrapedData;
    
  } catch (error) {
    console.error('❌ Scrape error:', error);
    return {
      success: false,
      error: error.message
    };
  }
});

// Função para enviar dados ao Rails
function sendToRails(data) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/deals/find_or_create',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };
    
    const req = http.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseData);
          resolve(parsed);
        } catch (e) {
          resolve({ status: 'ok', raw: responseData });
        }
      });
    });
    
    req.on('error', (error) => {
      reject(error);
    });
    
    req.write(postData);
    req.end();
  });
}

// IPC Handler: Injeta resposta no textarea de W1
ipcMain.handle('inject-response', async (event, responseText) => {
  try {
    console.log('💬 Injecting response into W1:', responseText.substring(0, 50) + '...');
    
    // Lê o script de injeção
    const injectorScript = fs.readFileSync(
      path.join(__dirname, 'injector.js'),
      'utf8'
    );
        // Injeta o script com o texto como parâmetro
    const result = await linkedinWindow.webContents.executeJavaScript(injectorScript);
    
    console.log('✅ Injection result:', result);
    return result;
    
  } catch (error) {
    console.error('❌ Injection error:', error);
    return {
      success: false,
      error: error.message
    };
  }
});

