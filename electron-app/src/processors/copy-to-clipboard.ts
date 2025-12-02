/**
 * Copy to Clipboard Processor
 * Copies image data to the system clipboard
 */

import { Processor, DataType } from '../types';
import { clipboard, nativeImage } from 'electron';

export const copyToClipboardProcessor: Processor = {
  id: 'copy-to-clipboard',
  name: 'Copy to Clipboard',
  description: 'Copies the image to the system clipboard',
  compatibleDataTypes: [DataType.IMAGE],
  
  async execute(data: any): Promise<any> {
    try {
      // Validate that we have image data
      if (!data || !data.base64) {
        throw new Error('Invalid image data: missing base64 content');
      }

      // Convert base64 to NativeImage
      const image = nativeImage.createFromBuffer(Buffer.from(data.base64, 'base64'));
      
      // Write to clipboard
      clipboard.writeImage(image);

      return {
        success: true,
        message: 'Image copied to clipboard successfully',
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

