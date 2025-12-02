/**
 * Universal Source - Available on all pages regardless of domain
 */

import { Source } from '../../types';
import { universalScenario } from './scenarios';

export const universalSource: Source = {
  id: 'universal',
  name: 'Universal',
  domains: [],  // Empty array means it applies to all domains
  scenarios: [universalScenario]
};

