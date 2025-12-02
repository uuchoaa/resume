/**
 * LinkedIn Chat - Inject Message Writer
 * Injects a message into the LinkedIn chat textarea
 */

import { Writer } from '../../../../../types';

export const injectMessage: Writer = {
  id: 'inject-message',
  name: 'Inject Message',
  description: 'Injects text into the LinkedIn chat message box',
  testFixture: 'chat.html',
  script: `
(async () => {
  try {
    // __INPUT_DATA__ is injected by the executor when this script runs
    const messageText = typeof __INPUT_DATA__ === 'string' ? __INPUT_DATA__ : __INPUT_DATA__?.text || '';
    
    if (!messageText) {
      return {
        success: false,
        error: 'No message text provided'
      };
    }

    // Find the message textarea
    const textarea = document.querySelector('.msg-form__contenteditable, [contenteditable="true"].msg-form__msg-content-container--scrollable');
    
    if (!textarea) {
      return {
        success: false,
        error: 'Message textarea not found'
      };
    }

    // Set the text
    if (textarea.getAttribute('contenteditable') === 'true') {
      // ContentEditable div
      textarea.textContent = messageText;
      
      // Trigger input event to enable send button
      const inputEvent = new Event('input', { bubbles: true });
      textarea.dispatchEvent(inputEvent);
    } else {
      // Regular textarea
      textarea.value = messageText;
      
      // Trigger input event
      const inputEvent = new Event('input', { bubbles: true });
      textarea.dispatchEvent(inputEvent);
    }

    return {
      success: true,
      message: 'Text injected successfully',
      length: messageText.length
    };
    
  } catch (error) {
    return {
      success: false,
      error: error.message,
      stack: error.stack
    };
  }
})();
  `.trim()
};

