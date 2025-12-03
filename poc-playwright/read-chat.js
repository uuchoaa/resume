#!/usr/bin/env node

/**
 * LinkedIn Chat Reader
 * Reads all messages from a LinkedIn chat conversation
 * 
 * Usage: node read-chat.js <CHAT_URL>
 * Example: node read-chat.js "https://www.linkedin.com/messaging/thread/2-XXXXX"
 */

import { chromium } from 'playwright';
import { readFileSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Configuration
const HEADLESS = process.env.HEADLESS !== 'false';
const SLOW_MO = parseInt(process.env.SLOW_MO || '0');
const TIMEOUT = 30000;

// Load and normalize cookies
function loadCookies() {
  const cookiesPath = join(__dirname, 'cookies.json');
  
  if (!existsSync(cookiesPath)) {
    console.error('❌ Error: cookies.json not found');
    console.error('Please create cookies.json with your LinkedIn cookies.');
    console.error('See README.md for instructions.');
    process.exit(1);
  }
  
  try {
    const cookiesData = readFileSync(cookiesPath, 'utf-8');
    const cookies = JSON.parse(cookiesData);
    
    // Normalize cookies for Playwright
    return cookies.map(cookie => {
      // Normalize sameSite
      let sameSite = cookie.sameSite;
      if (!sameSite || !['Strict', 'Lax', 'None'].includes(sameSite)) {
        sameSite = 'Lax'; // Default safe value
      }
      
      // Ensure domain starts with . for subdomain matching
      let domain = cookie.domain;
      if (domain && !domain.startsWith('.') && domain.includes('linkedin')) {
        domain = '.' + domain;
      }
      
      return {
        name: cookie.name,
        value: cookie.value,
        domain: domain || '.linkedin.com',
        path: cookie.path || '/',
        expires: cookie.expirationDate || cookie.expires || -1,
        httpOnly: cookie.httpOnly || false,
        secure: cookie.secure !== false, // Default to true
        sameSite: sameSite
      };
    });
  } catch (error) {
    console.error('❌ Error parsing cookies.json:', error.message);
    process.exit(1);
  }
}

// Extract conversation data from page
async function extractConversation(page) {
  return await page.evaluate(() => {
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
      
      console.log(`Found ${messageElements.length} message elements`);
      
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
              const timestampMatch = decoded.match(/\d{13,}/);
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

      return scrapedData;
      
    } catch (error) {
      return {
        success: false,
        error: error.message,
        stack: error.stack
      };
    }
  });
}

// Main function
async function main() {
  const chatUrl = process.argv[2];
  
  if (!chatUrl) {
    console.error('❌ Error: Chat URL is required');
    console.error('Usage: node read-chat.js <CHAT_URL>');
    console.error('Example: node read-chat.js "https://www.linkedin.com/messaging/thread/2-XXXXX"');
    process.exit(1);
  }
  
  if (!chatUrl.includes('linkedin.com')) {
    console.error('❌ Error: URL must be a LinkedIn URL');
    process.exit(1);
  }
  
  console.log('🚀 Starting LinkedIn Chat Reader...');
  console.log(`📍 Target URL: ${chatUrl}`);
  console.log(`👁️  Headless: ${HEADLESS}`);
  
  // Load cookies
  const cookies = loadCookies();
  console.log(`🍪 Loaded ${cookies.length} cookies`);
  
  // Launch browser
  const browser = await chromium.launch({
    headless: HEADLESS,
    slowMo: SLOW_MO
  });
  
  const context = await browser.newContext();
  
  // Add cookies
  await context.addCookies(cookies);
  console.log('✅ Cookies injected');
  
  const page = await context.newPage();
  
  try {
    // Navigate to chat
    console.log('🌐 Navigating to chat...');
    await page.goto(chatUrl, { 
      waitUntil: 'domcontentloaded',
      timeout: TIMEOUT 
    });
    
    // Wait for chat to load
    console.log('⏳ Waiting for chat to load...');
    await page.waitForSelector('.msg-s-message-list__event, .msg-s-event-listitem', { 
      timeout: TIMEOUT 
    });
    
    console.log('✅ Chat loaded!');
    
    // Give it a moment for dynamic content
    console.log('⏳ Loading all messages...');
    await page.waitForTimeout(3000);
    
    // Extract conversation
    console.log('📖 Extracting conversation...');
    const result = await extractConversation(page);
    
    if (result.success) {
      console.log('\n✅ Extraction successful!');
      console.log(`👤 Contact: ${result.contact.name || 'Unknown'}`);
      console.log(`💬 Total messages: ${result.totalMessages}`);
      console.log('\n📄 Full JSON output:\n');
      console.log(JSON.stringify(result, null, 2));
      
      // If running with visible browser, wait for user to review
      if (!HEADLESS) {
        console.log('\n⏸️  Browser will stay open for 5 seconds so you can review...');
        console.log('💡 Press Ctrl+C to close earlier');
        await page.waitForTimeout(5000);
      }
    } else {
      console.error('\n❌ Extraction failed:', result.error);
      console.error('Stack:', result.stack);
      process.exit(1);
    }
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    
    // Only try to take screenshot if page is still open
    try {
      const screenshotPath = join(__dirname, `error-${Date.now()}.png`);
      await page.screenshot({ path: screenshotPath, fullPage: true });
      console.error(`📸 Screenshot saved to: ${screenshotPath}`);
    } catch (screenshotError) {
      console.error('⚠️  Could not save screenshot (page was closed)');
    }
    
    process.exit(1);
  } finally {
    try {
      await browser.close();
    } catch (e) {
      // Browser already closed, ignore
    }
  }
}

// Run
main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});

