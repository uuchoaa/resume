/**
 * Temporary in-memory data store for the session
 * Stores extraction results and processed data
 */

import { DataRecord, ExecutionResult } from '../types';

export class DataStore {
  private records: Map<string, DataRecord> = new Map();
  private idCounter = 0;

  /**
   * Add a new execution result to the store
   */
  add(result: ExecutionResult): string {
    const id = `record-${Date.now()}-${this.idCounter++}`;
    const record: DataRecord = {
      id,
      result
    };
    this.records.set(id, record);
    return id;
  }

  /**
   * Get a specific record by ID
   */
  get(id: string): DataRecord | undefined {
    return this.records.get(id);
  }

  /**
   * Get all records
   */
  getAll(): DataRecord[] {
    return Array.from(this.records.values());
  }

  /**
   * Update a record with processed data
   */
  updateProcessed(id: string, processorId: string, processorName: string, output: any): boolean {
    const record = this.records.get(id);
    if (!record) return false;

    record.processed = {
      processorId,
      processorName,
      output,
      timestamp: new Date().toISOString()
    };
    return true;
  }

  /**
   * Clear all records
   */
  clear(): void {
    this.records.clear();
    this.idCounter = 0;
  }

  /**
   * Get records count
   */
  count(): number {
    return this.records.size;
  }
}

