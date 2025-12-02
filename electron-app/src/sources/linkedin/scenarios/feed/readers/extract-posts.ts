/**
 * LinkedIn Feed - Extract Posts Reader
 * Placeholder for future implementation
 */

import { Reader, DataType } from '../../../../../types';

export const extractPosts: Reader = {
  id: 'extract-posts',
  name: 'Extract Posts',
  description: 'Extracts posts from the LinkedIn feed (placeholder)',
  dataType: DataType.JSON,
  script: `
(async () => {
  return {
    success: false,
    error: 'Not implemented yet',
    message: 'This reader is a placeholder for future development'
  };
})();
  `.trim()
};

