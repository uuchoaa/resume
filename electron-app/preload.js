const { contextBridge, ipcRenderer } = require('electron');

// Expõe API segura para o renderer process
contextBridge.exposeInMainWorld('electronAPI', {
  // Funções serão adicionadas aqui depois
  test: () => console.log('Electron API working!')
});

console.log('Preload script loaded successfully');

