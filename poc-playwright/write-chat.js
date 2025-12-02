#!/usr/bin/env node

/**
 * LinkedIn Chat Writer
 * Injects a message into a LinkedIn chat conversation
 * NOTE: This only INJECTS the text, it does NOT send automatically
 * 
 * Usage: node write-chat.js <CHAT_URL> <MESSAGE>
 * Example: node write-chat.js "https://www.linkedin.com/messaging/thread/2-XXXXX" "Hello!"
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

// Load cookies
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
    return JSON.parse(cookiesData);
  } catch (error) {
    console.error('❌ Error parsing cookies.json:', error.message);
    process.exit(1);
  }
}

// Inject message into chat
async function injectMessage(page, messageText) {
  return await page.evaluate((text) => {
    try {
      if (!text) {
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
        textarea.textContent = text;
        
        // Trigger input event to enable send button
        const inputEvent = new Event('input', { bubbles: true });
        textarea.dispatchEvent(inputEvent);
      } else {
        // Regular textarea
        textarea.value = text;
        
        // Trigger input event
        const inputEvent = new Event('input', { bubbles: true });
        textarea.dispatchEvent(inputEvent);
      }

      return {
        success: true,
        message: 'Text injected successfully',
        length: text.length
      };
      
    } catch (error) {
      return {
        success: false,
        error: error.message,
        stack: error.stack
      };
    }
  }, messageText);
}

// Main function
async function main() {
  const chatUrl = process.argv[2];
  const messageText = process.argv[3];
  
  if (!chatUrl) {
    console.error('❌ Error: Chat URL is required');
    console.error('Usage: node write-chat.js <CHAT_URL> <MESSAGE>');
    console.error('Example: node write-chat.js "https://www.linkedin.com/messaging/thread/2-XXXXX" "Hello!"');
    process.exit(1);
  }
  
  if (!messageText) {
    console.error('❌ Error: Message text is required');
    console.error('Usage: node write-chat.js <CHAT_URL> <MESSAGE>');
    process.exit(1);
  }
  
  if (!chatUrl.includes('linkedin.com')) {
    console.error('❌ Error: URL must be a LinkedIn URL');
    process.exit(1);
  }
  
  console.log('🚀 Starting LinkedIn Chat Writer...');
  console.log(`📍 Target URL: ${chatUrl}`);
  console.log(`💬 Message: "${messageText}"`);
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
      waitUntil: 'networkidle',
      timeout: TIMEOUT 
    });
    
    // Wait for chat to load
    console.log('⏳ Waiting for chat to load...');
    await page.waitForSelector('.msg-form__contenteditable, [contenteditable="true"]', { 
      timeout: TIMEOUT 
    });
    
    // Give it a moment
    await page.waitForTimeout(1000);
    
    // Inject message
    console.log('✍️  Injecting message...');
    const result = await injectMessage(page, messageText);
    
    if (result.success) {
      console.log('\n✅ Message injected successfully!');
      console.log(`📝 Length: ${result.length} characters`);
      console.log('\n⚠️  IMPORTANT: The message was INJECTED but NOT sent automatically.');
      console.log('👁️  Please review the message in the browser and send it manually if correct.');
      
      if (HEADLESS) {
        console.log('\n💡 Tip: Run with HEADLESS=false to see the browser:');
        console.log(`   HEADLESS=false node write-chat.js "${chatUrl}" "${messageText}"`);
      } else {
        console.log('\n⏸️  Browser will stay open for 10 seconds so you can review...');
        await page.waitForTimeout(10000);
      }
    } else {
      console.error('\n❌ Failed to inject message:', result.error);
      if (result.stack) {
        console.error('Stack:', result.stack);
      }
      process.exit(1);
    }
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    
    // Take screenshot on error
    const screenshotPath = join(__dirname, `error-${Date.now()}.png`);
    await page.screenshot({ path: screenshotPath, fullPage: true });
    console.error(`📸 Screenshot saved to: ${screenshotPath}`);
    
    process.exit(1);
  } finally {
    if (!HEADLESS) {
      console.log('\n🔒 Closing browser...');
    }
    await browser.close();
  }
}

// Run
main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});

