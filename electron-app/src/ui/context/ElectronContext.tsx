import React, { createContext, useContext, useState, useCallback } from 'react';
import { useElectronAPI } from '../hooks/useElectronAPI';
import type { Source, Scenario, DataRecord, Processor } from '../types';

interface ElectronState {
  url: string;
  source: Source | null;
  scenario: Scenario | null;
  records: DataRecord[];
  processors: Processor[];
}

interface ElectronContextValue extends ElectronState {
  // Navigation
  navigateTo: (url: string) => Promise<void>;
  navigateBack: () => Promise<void>;
  navigateForward: () => Promise<void>;
  reload: () => Promise<void>;

  // Actions
  executeReader: (readerId: string) => Promise<void>;
  executeWriter: (writerId: string, inputData: string) => Promise<void>;

  // Data
  clearRecords: () => Promise<void>;
  
  // Processors
  executeProcessor: (recordId: string, processorId: string) => Promise<boolean>;
  
  // Screenshot
  captureAndSavePage: () => Promise<boolean>;
  captureToClipboard: () => Promise<boolean>;
  
  // Modals
  selectedRecord: DataRecord | null;
  setSelectedRecord: (record: DataRecord | null) => void;
}

const ElectronContext = createContext<ElectronContextValue | null>(null);

export function ElectronProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<ElectronState>({
    url: '',
    source: null,
    scenario: null,
    records: [],
    processors: []
  });

  const [selectedRecord, setSelectedRecord] = useState<DataRecord | null>(null);

  // Setup IPC event listeners
  useElectronAPI({
    onInitData: useCallback((data) => {
      console.log('Init data received:', data);
      setState(prev => ({
        ...prev,
        processors: data.processors
      }));
    }, []),

    onUrlChanged: useCallback((data) => {
      console.log('URL changed:', data);
      setState(prev => ({
        ...prev,
        url: data.url,
        source: data.source,
        scenario: data.scenario
      }));
    }, []),

    onDataUpdated: useCallback((records) => {
      console.log('Data updated:', records);
      setState(prev => ({
        ...prev,
        records
      }));
      
      // Update selected record if it's in the list
      setSelectedRecord(prevSelected => {
        if (!prevSelected) return null;
        return records.find(r => r.id === prevSelected.id) || null;
      });
    }, [])
  });

  // Navigation methods
  const navigateTo = useCallback(async (url: string) => {
    if (!window.electronAPI) return;
    const result = await window.electronAPI.navigateTo(url);
    if (!result.success) {
      console.error('Navigation failed:', result.error);
    }
  }, []);

  const navigateBack = useCallback(async () => {
    if (!window.electronAPI) return;
    await window.electronAPI.navigateBack();
  }, []);

  const navigateForward = useCallback(async () => {
    if (!window.electronAPI) return;
    await window.electronAPI.navigateForward();
  }, []);

  const reload = useCallback(async () => {
    if (!window.electronAPI) return;
    await window.electronAPI.reload();
  }, []);

  // Action methods
  const executeReader = useCallback(async (readerId: string) => {
    if (!window.electronAPI || !state.source || !state.scenario) return;
    
    console.log('Executing reader:', readerId);
    const result = await window.electronAPI.executeReader(
      state.source.id,
      state.scenario.id,
      readerId
    );
    console.log('Reader result:', result);
  }, [state.source, state.scenario]);

  const executeWriter = useCallback(async (writerId: string, inputData: string) => {
    if (!window.electronAPI || !state.source || !state.scenario) return;
    
    console.log('Executing writer:', writerId, 'with input:', inputData);
    const result = await window.electronAPI.executeWriter(
      state.source.id,
      state.scenario.id,
      writerId,
      inputData
    );
    console.log('Writer result:', result);
  }, [state.source, state.scenario]);

  // Data methods
  const clearRecords = useCallback(async () => {
    if (!window.electronAPI) return;
    if (confirm('Clear all data history?')) {
      await window.electronAPI.clearRecords();
    }
  }, []);

  // Processor methods
  const executeProcessor = useCallback(async (recordId: string, processorId: string): Promise<boolean> => {
    if (!window.electronAPI) return false;
    
    console.log('Applying processor:', processorId, 'to record:', recordId);
    const result = await window.electronAPI.executeProcessor(recordId, processorId);
    console.log('Processor result:', result);
    
    return result.success;
  }, []);

  // Screenshot methods
  const captureAndSavePage = useCallback(async (): Promise<boolean> => {
    if (!window.electronAPI) return false;
    
    const result = await window.electronAPI.captureAndSavePage();
    if (result.success) {
      console.log('Screenshot saved:', result.fileName);
      alert(`Screenshot saved to Downloads:\n${result.fileName}`);
      return true;
    }
    
    console.error('Save failed:', result.error);
    alert(`Failed to save screenshot:\n${result.error}`);
    return false;
  }, []);

  const captureToClipboard = useCallback(async (): Promise<boolean> => {
    if (!window.electronAPI) return false;
    
    const result = await window.electronAPI.captureToClipboard();
    if (result.success) {
      console.log('Screenshot copied to clipboard');
      alert('Screenshot copied to clipboard!');
      return true;
    }
    
    console.error('Copy failed:', result.error);
    alert(`Failed to copy screenshot:\n${result.error}`);
    return false;
  }, []);

  const value: ElectronContextValue = {
    ...state,
    navigateTo,
    navigateBack,
    navigateForward,
    reload,
    executeReader,
    executeWriter,
    clearRecords,
    executeProcessor,
    captureAndSavePage,
    captureToClipboard,
    selectedRecord,
    setSelectedRecord
  };

  return (
    <ElectronContext.Provider value={value}>
      {children}
    </ElectronContext.Provider>
  );
}

export function useElectron() {
  const context = useContext(ElectronContext);
  if (!context) {
    throw new Error('useElectron must be used within ElectronProvider');
  }
  return context;
}

