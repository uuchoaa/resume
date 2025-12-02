/**
 * Processors Registry
 * Import and export all processors here
 */

import { Processor } from '../types';
import { summarizeProcessor } from './summarize';
import { exportJsonProcessor } from './export-json';
import { copyToClipboardProcessor } from './copy-to-clipboard';
import { downloadFileProcessor } from './download-file';

// Export all processors as an array
export const allProcessors: Processor[] = [
  summarizeProcessor,
  exportJsonProcessor,
  copyToClipboardProcessor,
  downloadFileProcessor
  // Add more processors here as they are created
];

