/**
 * Summarize Processor
 * Creates a simple summary of extracted data
 */

import { Processor, DataType } from '../types';

export const summarizeProcessor: Processor = {
  id: 'summarize',
  name: 'Summarize',
  description: 'Creates a basic summary of the extracted data',
  compatibleDataTypes: [DataType.TEXT, DataType.JSON],
  
  async execute(data: any): Promise<any> {
    try {
      const summary: any = {
        timestamp: new Date().toISOString(),
        dataType: typeof data,
        summary: {}
      };

      // If it's the LinkedIn chat extraction
      if (data && data.contact && data.messages) {
        summary.type = 'LinkedIn Chat';
        summary.summary = {
          contactName: data.contact.name || 'Unknown',
          contactHeadline: data.contact.headline || 'N/A',
          totalMessages: data.totalMessages || 0,
          messagesExtracted: data.messages?.length || 0,
          conversationUrl: data.url,
          extractedAt: data.timestamp
        };

        // Message breakdown by sender
        if (data.messages && Array.isArray(data.messages)) {
          const senders = data.messages.reduce((acc: any, msg: any) => {
            acc[msg.sender] = (acc[msg.sender] || 0) + 1;
            return acc;
          }, {});
          summary.summary.messagesBySender = senders;
        }
      } else {
        // Generic summary
        summary.type = 'Generic Data';
        summary.summary = {
          keys: Object.keys(data || {}),
          objectCount: Array.isArray(data) ? data.length : 1,
          preview: JSON.stringify(data).substring(0, 200) + '...'
        };
      }

      return {
        success: true,
        summary
      };
    } catch (error: any) {
      return {
        success: false,
        error: error.message
      };
    }
  }
};

