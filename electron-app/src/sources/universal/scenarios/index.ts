/**
 * Universal Scenario - Available on all pages
 */

import { Scenario } from '../../../types';
import { screenshotReader } from '../readers/screenshot';

export const universalScenario: Scenario = {
  id: 'universal',
  name: 'Universal',
  urlPattern: /.*/,  // Matches all URLs
  readers: [screenshotReader],
  writers: []
};

