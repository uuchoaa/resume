/**
 * Core type definitions for the modular scraping architecture
 */

/**
 * DataType represents the type of data extracted by a Reader
 */
export enum DataType {
  TEXT = 'text',
  JSON = 'json',
  IMAGE = 'image',
  BINARY = 'binary'
}

/**
 * Source represents a website/platform (e.g., LinkedIn, Calendly)
 */
export interface Source {
  id: string;           // 'linkedin', 'calendly'
  name: string;         // 'LinkedIn', 'Calendly'
  domains: string[];    // ['linkedin.com', 'www.linkedin.com']
  scenarios: Scenario[];
}

/**
 * Scenario represents a specific context within a source (e.g., LinkedIn Chat, LinkedIn Feed)
 * Detected automatically via URL pattern matching
 */
export interface Scenario {
  id: string;           // 'linkedin-chat', 'linkedin-feed'
  name: string;         // 'LinkedIn Chat', 'LinkedIn Feed'
  urlPattern: RegExp;   // Pattern to match URLs
  readers: Reader[];    // Available read actions
  writers: Writer[];    // Available write actions
}

/**
 * Reader extracts data from a page (read operation)
 */
export interface Reader {
  id: string;           // 'extract-conversation'
  name: string;         // 'Extract Conversation'
  description: string;  // Human-readable description
  dataType: DataType;   // Type of data this reader extracts
  script: string;       // JavaScript code to inject and execute
  testFixture?: string; // Optional path to test HTML file
}

/**
 * Writer injects data into a page (write operation)
 */
export interface Writer {
  id: string;           // 'inject-message'
  name: string;         // 'Inject Message'
  description: string;  // Human-readable description
  script: string;       // JavaScript code to inject and execute
  testFixture?: string; // Optional path to test HTML file
}

/**
 * Processor processes extracted data (summarize, export, etc)
 */
export interface Processor {
  id: string;           // 'summarize', 'export-json'
  name: string;         // 'Summarize', 'Export JSON'
  description: string;  // Human-readable description
  compatibleDataTypes: DataType[]; // Data types this processor can handle
  execute: (data: any) => Promise<any>; // Processing function
}

/**
 * ExecutionResult represents the result of executing a reader or writer
 */
export interface ExecutionResult {
  success: boolean;
  data?: any;
  error?: string;
  timestamp: string;
  actionId: string;
  actionName: string;
  dataType?: DataType;  // Type of data (for readers)
  scenarioId: string;
  sourceId: string;
  url: string;
}

/**
 * DataRecord is stored in the temp data store during the session
 */
export interface DataRecord {
  id: string;           // Unique ID for the record
  result: ExecutionResult;
  processed?: {         // Optional processed data
    processorId: string;
    processorName: string;
    output: any;
    timestamp: string;
  };
}

