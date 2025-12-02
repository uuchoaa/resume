/**
 * Export JSON Processor
 * Exports data as formatted JSON
 */

import { Processor, DataType } from '../types';
import * as fs from 'fs';
import * as path from 'path';
import { app } from 'electron';

export const exportJsonProcessor: Processor = {
  id: 'export-json',
  name: 'Export JSON',
  description: 'Exports the extracted data as a formatted JSON file',
  compatibleDataTypes: [DataType.TEXT, DataType.JSON],
  
  async execute(data: any): Promise<any> {
    try {
      // Create exports directory if it doesn't exist
      const exportDir = path.join(app.getPath('userData'), 'exports');
      if (!fs.existsSync(exportDir)) {
        fs.mkdirSync(exportDir, { recursive: true });
      }

      // Generate filename with timestamp
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const filename = `export-${timestamp}.json`;
      const filepath = path.join(exportDir, filename);

      // Write JSON file
      fs.writeFileSync(filepath, JSON.stringify(data, null, 2), 'utf-8');

      return {
        success: true,
        message: 'Data exported successfully',
        filepath,
        filename,
        size: fs.statSync(filepath).size
      };
    } catch (error: any) {
      return {
        success: false,
        error: error.message
      };
    }
  }
};

