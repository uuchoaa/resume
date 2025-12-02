import { useEffect } from 'react';
import type { Source, Scenario, DataRecord, Processor } from '../types';

interface UseElectronAPICallbacks {
  onInitData?: (data: { sources: Source[]; processors: Processor[] }) => void;
  onUrlChanged?: (data: { url: string; source: Source | null; scenario: Scenario | null }) => void;
  onDataUpdated?: (records: DataRecord[]) => void;
}

export function useElectronAPI(callbacks: UseElectronAPICallbacks) {
  useEffect(() => {
    if (!window.electronAPI) {
      console.error('electronAPI not available');
      return;
    }

    // Setup event listeners
    if (callbacks.onInitData) {
      window.electronAPI.onInitData(callbacks.onInitData);
    }

    if (callbacks.onUrlChanged) {
      window.electronAPI.onUrlChanged(callbacks.onUrlChanged);
    }

    if (callbacks.onDataUpdated) {
      window.electronAPI.onDataUpdated(callbacks.onDataUpdated);
    }
  }, [callbacks.onInitData, callbacks.onUrlChanged, callbacks.onDataUpdated]);
}

