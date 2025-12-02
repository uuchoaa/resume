/**
 * Calendly Source Definition
 */

import { Source } from '../../types';
import { calendlyConfirmationScenario } from './scenarios/confirmation';

export const calendlySource: Source = {
  id: 'calendly',
  name: 'Calendly',
  domains: ['calendly.com'],
  scenarios: [calendlyConfirmationScenario]
};

