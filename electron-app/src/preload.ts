/**
 * Preload Script - IPC Bridge
 * Exposes safe IPC methods to renderer processes
 */

import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('electronAPI', {
  // Navigation
  getCurrentUrl: () => ipcRenderer.invoke('get-current-url'),
  navigateTo: (url: string) => ipcRenderer.invoke('navigate-to', url),
  navigateBack: () => ipcRenderer.invoke('navigate-back'),
  navigateForward: () => ipcRenderer.invoke('navigate-forward'),
  reload: () => ipcRenderer.invoke('reload'),

  // Actions
  executeReader: (sourceId: string, scenarioId: string, readerId: string) => 
    ipcRenderer.invoke('execute-reader', sourceId, scenarioId, readerId),
  executeWriter: (sourceId: string, scenarioId: string, writerId: string, inputData: any) => 
    ipcRenderer.invoke('execute-writer', sourceId, scenarioId, writerId, inputData),

  // Data
  getAllRecords: () => ipcRenderer.invoke('get-all-records'),
  clearRecords: () => ipcRenderer.invoke('clear-records'),

  // Processors
  executeProcessor: (recordId: string, processorId: string) => 
    ipcRenderer.invoke('execute-processor', recordId, processorId),

  // Screenshot
  captureAndSavePage: () => ipcRenderer.invoke('capture-and-save-page'),
  captureToClipboard: () => ipcRenderer.invoke('capture-to-clipboard'),

  // Event listeners
  onInitData: (callback: (data: any) => void) => {
    ipcRenderer.on('init-data', (event, data) => callback(data));
  },
  onUrlChanged: (callback: (data: any) => void) => {
    ipcRenderer.on('url-changed', (event, data) => callback(data));
  },
  onDataUpdated: (callback: (records: any[]) => void) => {
    ipcRenderer.on('data-updated', (event, records) => callback(records));
  }
});

