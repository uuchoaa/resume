/**
 * LinkedIn Feed Scenario
 */

import { Scenario } from '../../../../types';
import { extractPosts } from './readers/extract-posts';

export const linkedinFeedScenario: Scenario = {
  id: 'linkedin-feed',
  name: 'LinkedIn Feed',
  urlPattern: /linkedin\.com\/feed/,
  readers: [extractPosts],
  writers: []
};

