/**
 * Download File Processor
 * Downloads image data to the Downloads folder
 */

import { Processor, DataType } from '../types';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

export const downloadFileProcessor: Processor = {
  id: 'download-file',
  name: 'Download File',
  description: 'Downloads the image to your Downloads folder',
  compatibleDataTypes: [DataType.IMAGE],
  
  async execute(data: any): Promise<any> {
    try {
      // Validate that we have image data
      if (!data || !data.base64) {
        throw new Error('Invalid image data: missing base64 content');
      }

      // Get Downloads folder
      const downloadsPath = path.join(os.homedir(), 'Downloads');
      
      // Generate filename with timestamp
      const timestamp = new Date().toISOString().replace(/:/g, '-').split('.')[0];
      const fileName = `screenshot-${timestamp}.png`;
      const filePath = path.join(downloadsPath, fileName);

      // Convert base64 to buffer and save
      const buffer = Buffer.from(data.base64, 'base64');
      fs.writeFileSync(filePath, buffer);
      
      const fileSize = fs.statSync(filePath).size;

      return {
        success: true,
        message: 'Image downloaded successfully',
        filePath,
        fileName,
        size: fileSize,
        width: data.width,
        height: data.height
      };
    } catch (error: any) {
      return {
        success: false,
        error: error.message
      };
    }
  }
};

