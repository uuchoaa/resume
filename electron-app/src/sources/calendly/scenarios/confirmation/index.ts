/**
 * Calendly Confirmation Scenario
 */

import { Scenario } from '../../../../types';
import { extractBooking } from './readers/extract-booking';

export const calendlyConfirmationScenario: Scenario = {
  id: 'calendly-confirmation',
  name: 'Calendly Confirmation',
  urlPattern: /calendly\.com\/[^/]+\/[^/]+\/(confirmed|scheduled)/,
  readers: [extractBooking],
  writers: []
};

