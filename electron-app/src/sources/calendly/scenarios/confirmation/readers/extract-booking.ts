/**
 * Calendly Confirmation - Extract Booking Reader
 * Extracts booking details from Calendly confirmation page
 */

import { Reader, DataType } from '../../../../../types';

export const extractBooking: Reader = {
  id: 'extract-booking',
  name: 'Extract Booking',
  description: 'Extracts meeting details, date, time, and participant info from Calendly confirmation',
  dataType: DataType.JSON,
  testFixture: 'confirmation.html',
  script: `
(async () => {
  try {
    // Extract meeting title
    const title = document.querySelector('h1, .event-title, [data-component="event-name"]')?.textContent?.trim();
    
    // Extract date and time
    const dateTime = document.querySelector('.event-date, [data-component="event-date"]')?.textContent?.trim();
    
    // Extract organizer info
    const organizer = document.querySelector('.organizer-name, [data-component="organizer"]')?.textContent?.trim();
    
    // Extract location/meeting link
    const location = document.querySelector('.location, [data-component="location"], a[href*="zoom"], a[href*="meet.google"]')?.textContent?.trim();
    const meetingLink = document.querySelector('a[href*="zoom"], a[href*="meet.google"]')?.getAttribute('href');
    
    // Extract invitee info (if available)
    const inviteeName = document.querySelector('.invitee-name, [data-component="invitee-name"]')?.textContent?.trim();
    const inviteeEmail = document.querySelector('.invitee-email, [data-component="invitee-email"]')?.textContent?.trim();
    
    // Extract any additional notes
    const notes = document.querySelector('.event-notes, .description, [data-component="notes"]')?.textContent?.trim();
    
    const bookingData = {
      success: true,
      meeting: {
        title: title,
        dateTime: dateTime,
        organizer: organizer,
        location: location,
        meetingLink: meetingLink,
        notes: notes
      },
      invitee: {
        name: inviteeName,
        email: inviteeEmail
      },
      url: window.location.href,
      timestamp: new Date().toISOString()
    };

    console.log('Extracted booking data:', bookingData);
    return bookingData;
    
  } catch (error) {
    console.error('Extraction error:', error);
    return {
      success: false,
      error: error.message,
      stack: error.stack
    };
  }
})();
  `.trim()
};

