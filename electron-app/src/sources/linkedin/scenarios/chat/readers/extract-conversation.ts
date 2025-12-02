/**
 * LinkedIn Chat - Extract Conversation Reader
 * Extracts messages and contact information from LinkedIn chat
 */

import { Reader, DataType } from '../../../../../types';

export const extractConversation: Reader = {
  id: 'extract-conversation',
  name: 'Extract Conversation',
  description: 'Extracts all messages and contact info from the current LinkedIn chat',
  dataType: DataType.JSON,
  testFixture: 'chat.html',
  script: `
(async () => {
  try {
    const messages = [];
    
    // Extract contact information
    const contactInfo = {};
    
    // Name and profile link
    const profileLink = document.querySelector('.msg-thread__link-to-profile');
    if (profileLink) {
      contactInfo.profileUrl = profileLink.getAttribute('href');
      contactInfo.name = profileLink.getAttribute('title')?.replace("Open ", "")?.replace("'s profile", "") || null;
    }
    
    // Alternative name and info
    const entityTitle = document.querySelector('.msg-entity-lockup__entity-title');
    if (entityTitle && !contactInfo.name) {
      contactInfo.name = entityTitle.textContent?.trim();
    }
    
    // Title/position/company
    const entityInfo = document.querySelector('.msg-entity-lockup__entity-info');
    if (entityInfo) {
      contactInfo.headline = entityInfo.textContent?.trim();
    }
    
    // Profile photo
    const profileImage = document.querySelector('.msg-thread img, .msg-entity-lockup img');
    if (profileImage) {
      contactInfo.photoUrl = profileImage.getAttribute('src');
      contactInfo.photoAlt = profileImage.getAttribute('alt');
    }
    
    // Find message elements
    const messageElements = document.querySelectorAll('.msg-s-message-list__event');
    
    console.log(\`Found \${messageElements.length} message elements\`);
    
    // Extract information from each message
    messageElements.forEach((element, index) => {
      // Get conversation date if exists
      const dateHeading = element.querySelector('.msg-s-message-list__time-heading');
      const conversationDate = dateHeading?.textContent?.trim() || null;
      
      // Get message container
      const eventItem = element.querySelector('.msg-s-event-listitem');
      if (!eventItem) return;
      
      // Extract timestamp from URN if available
      const urnAttr = eventItem.getAttribute('data-event-urn');
      let messageTimestamp = null;
      if (urnAttr) {
        const match = urnAttr.match(/2-([A-Za-z0-9]+)/);
        if (match) {
          try {
            const decoded = atob(match[1]);
            const timestampMatch = decoded.match(/\\d{13,}/);
            if (timestampMatch) {
              messageTimestamp = new Date(parseInt(timestampMatch[0]));
            }
          } catch (e) {
            // Ignore decode errors
          }
        }
      }
      
      // Extract message text
      const textEl = eventItem.querySelector('.msg-s-event-listitem__body');
      const text = textEl?.textContent?.trim() || '';
      
      // Extract sender
      const senderEl = eventItem.querySelector('.msg-s-message-group__name');
      const sender = senderEl?.textContent?.trim() || 'Unknown';
      
      // Extract timestamp (time)
      const timeEl = eventItem.querySelector('.msg-s-message-group__timestamp');
      const time = timeEl?.textContent?.trim() || '';
      
      if (text && text.length > 0) {
        messages.push({
          index: index + 1,
          sender: sender,
          text: text,
          time: time,
          conversationDate: conversationDate,
          absoluteDate: messageTimestamp ? messageTimestamp.toISOString() : null,
          dateDisplay: messageTimestamp ? messageTimestamp.toLocaleString() : null
        });
      }
    });

    const scrapedData = {
      success: true,
      contact: contactInfo,
      totalMessages: messages.length,
      messages: messages,
      url: window.location.href,
      timestamp: new Date().toISOString(),
      pageTitle: document.title
    };

    console.log('Scraped data:', scrapedData);
    return scrapedData;
    
  } catch (error) {
    console.error('Scrape error:', error);
    return {
      success: false,
      error: error.message,
      stack: error.stack
    };
  }
})();
  `.trim()
};

