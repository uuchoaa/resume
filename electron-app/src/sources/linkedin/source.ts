/**
 * LinkedIn Source Definition
 */

import { Source } from '../../types';
import { linkedinChatScenario } from './scenarios/chat';
import { linkedinFeedScenario } from './scenarios/feed';

export const linkedinSource: Source = {
  id: 'linkedin',
  name: 'LinkedIn',
  domains: ['linkedin.com', 'www.linkedin.com'],
  scenarios: [
    linkedinChatScenario,
    linkedinFeedScenario
  ]
};

