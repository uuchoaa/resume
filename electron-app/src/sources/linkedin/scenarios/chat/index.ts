/**
 * LinkedIn Chat Scenario
 */

import { Scenario } from '../../../../types';
import { extractConversation } from './readers/extract-conversation';
import { injectMessage } from './writers/inject-message';

export const linkedinChatScenario: Scenario = {
  id: 'linkedin-chat',
  name: 'LinkedIn Chat',
  urlPattern: /linkedin\.com\/messaging/,
  readers: [extractConversation],
  writers: [injectMessage]
};

