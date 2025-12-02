/**
 * Universal Screenshot Reader
 * Captures a screenshot of the current page
 */

import { Reader, DataType } from '../../../types';

export const screenshotReader: Reader = {
  id: 'screenshot',
  name: 'Screenshot',
  description: 'Capture a screenshot of the current page',
  dataType: DataType.IMAGE,
  script: `
// This is a special marker that tells ActionExecutor to capture a screenshot
// instead of executing JavaScript on the page
({ __screenshot__: true })
  `.trim()
};

