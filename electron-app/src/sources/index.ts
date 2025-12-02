/**
 * Sources Registry
 * Import and export all sources here
 */

import { Source } from '../types';
import { universalSource } from './universal/source';
import { linkedinSource } from './linkedin/source';
import { calendlySource } from './calendly/source';

// Export all sources as an array
// Note: Universal source should be first so its actions are available everywhere
export const allSources: Source[] = [
  universalSource,
  linkedinSource,
  calendlySource
  // Add more sources here as they are created
];

