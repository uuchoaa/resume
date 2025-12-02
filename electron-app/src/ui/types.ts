export interface Source {
  id: string;
  name: string;
}

export interface Scenario {
  id: string;
  name: string;
  readers: Action[];
  writers: Action[];
}

export interface Action {
  id: string;
  name: string;
  description: string;
}

export interface Processor {
  id: string;
  name: string;
  description: string;
  compatibleDataTypes: string[];  // Array of DataType values
}

export interface BookmarkEntry {
  url: string;
  title: string;
  timestamp: string;
}

export interface DataRecord {
  id: string;
  result: {
    success: boolean;
    timestamp: string;
    actionName: string;
    dataType?: string;  // DataType of the extracted data
    sourceId: string;
    scenarioId: string;
    data?: any;
    error?: string;
  };
  processed?: {
    processorId: string;
    processorName: string;
    timestamp: string;
    data: any;
  };
}

export interface ElectronAPI {
  // Navigation
  getCurrentUrl: () => Promise<string | null>;
  navigateTo: (url: string) => Promise<{ success: boolean; error?: string }>;
  navigateBack: () => Promise<{ success: boolean }>;
  navigateForward: () => Promise<{ success: boolean }>;
  reload: () => Promise<{ success: boolean }>;

  // Actions
  executeReader: (sourceId: string, scenarioId: string, readerId: string) => Promise<any>;
  executeWriter: (sourceId: string, scenarioId: string, writerId: string, inputData: any) => Promise<any>;

  // Data
  getAllRecords: () => Promise<DataRecord[]>;
  clearRecords: () => Promise<{ success: boolean }>;

  // Processors
  executeProcessor: (recordId: string, processorId: string) => Promise<{ success: boolean; output?: any; error?: string }>;

  // Bookmarks
  getBookmarks: () => Promise<BookmarkEntry[]>;
  addBookmark: () => Promise<{ success: boolean; message?: string; error?: string }>;
  removeBookmark: (url: string) => Promise<{ success: boolean }>;
  isBookmarked: () => Promise<boolean>;
  navigateToBookmark: (url: string) => Promise<{ success: boolean; error?: string }>;
  
  // Navigation
  clearHistory: () => Promise<{ success: boolean; error?: string }>;
  loadWelcome: () => Promise<{ success: boolean; error?: string }>;

  // Event listeners
  onInitData: (callback: (data: { sources: Source[]; processors: Processor[] }) => void) => void;
  onUrlChanged: (callback: (data: { url: string; source: Source | null; scenario: Scenario | null }) => void) => void;
  onDataUpdated: (callback: (records: DataRecord[]) => void) => void;
}

declare global {
  interface Window {
    electronAPI: ElectronAPI;
  }
}

