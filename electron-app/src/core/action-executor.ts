/**
 * Action Executor - Executes readers and writers by injecting scripts
 */

import { BrowserWindow } from 'electron';
import { Reader, Writer, ExecutionResult } from '../types';

export class ActionExecutor {
  /**
   * Get image dimensions from PNG buffer
   */
  private async getImageDimensions(buffer: Buffer): Promise<{ width: number; height: number }> {
    // PNG signature is 8 bytes, then IHDR chunk
    // Width is at bytes 16-19, height at bytes 20-23
    if (buffer.length >= 24) {
      const width = buffer.readUInt32BE(16);
      const height = buffer.readUInt32BE(20);
      return { width, height };
    }
    return { width: 0, height: 0 };
  }

  /**
   * Execute a reader on a browser window
   */
  async executeReader(
    window: BrowserWindow,
    reader: Reader,
    sourceId: string,
    scenarioId: string
  ): Promise<ExecutionResult> {
    try {
      const url = window.webContents.getURL();
      const scriptResult = await window.webContents.executeJavaScript(reader.script);

      let data = scriptResult;

      // Check if this is a screenshot reader (special marker)
      if (scriptResult && typeof scriptResult === 'object' && scriptResult.__screenshot__) {
        // Scroll to top first
        await window.webContents.executeJavaScript('window.scrollTo(0, 0);');
        await new Promise(resolve => setTimeout(resolve, 100));

        console.log('Screenshot: Attempting full page capture via CDP');

        let debuggerAttached = false;
        try {
          // Attach debugger if not already attached
          if (!window.webContents.debugger.isAttached()) {
            console.log('Screenshot: Attaching debugger...');
            window.webContents.debugger.attach('1.3');
            debuggerAttached = true;
          }

          // Use Chrome DevTools Protocol for full page screenshot
          console.log('Screenshot: Sending Page.captureScreenshot command...');
          const result = await window.webContents.debugger.sendCommand('Page.captureScreenshot', {
            format: 'png',
            captureBeyondViewport: true
          });

          const base64 = result.data;
          
          // Get image dimensions from base64
          const buffer = Buffer.from(base64, 'base64');
          const { width, height } = await this.getImageDimensions(buffer);

          console.log('Screenshot: Captured full page via CDP:', { width, height });

          data = {
            format: 'png',
            base64: base64,
            width: width,
            height: height,
            dataUrl: `data:image/png;base64,${base64}`
          };
        } catch (error: any) {
          console.error('Screenshot: CDP failed:', error.message);
          
          // Fallback to standard capture
          console.log('Screenshot: Falling back to standard capturePage');
          const image = await window.capturePage();
          const size = image.getSize();
          const base64 = image.toPNG().toString('base64');
          
          data = {
            format: 'png',
            base64: base64,
            width: size.width,
            height: size.height,
            dataUrl: `data:image/png;base64,${base64}`
          };
        } finally {
          // Detach debugger if we attached it
          if (debuggerAttached && window.webContents.debugger.isAttached()) {
            console.log('Screenshot: Detaching debugger');
            window.webContents.debugger.detach();
          }
        }
      }

      return {
        success: true,
        data,
        timestamp: new Date().toISOString(),
        actionId: reader.id,
        actionName: reader.name,
        dataType: reader.dataType,
        scenarioId,
        sourceId,
        url
      };
    } catch (error: any) {
      return {
        success: false,
        error: error.message,
        timestamp: new Date().toISOString(),
        actionId: reader.id,
        actionName: reader.name,
        dataType: reader.dataType,
        scenarioId,
        sourceId,
        url: window.webContents.getURL()
      };
    }
  }

  /**
   * Execute a writer on a browser window
   */
  async executeWriter(
    window: BrowserWindow,
    writer: Writer,
    sourceId: string,
    scenarioId: string,
    inputData?: any
  ): Promise<ExecutionResult> {
    try {
      const url = window.webContents.getURL();
      
      // Inject input data as a global variable before executing the script
      let scriptWithData = writer.script;
      if (inputData !== undefined) {
        scriptWithData = `
          (function() {
            const __INPUT_DATA__ = ${JSON.stringify(inputData)};
            ${writer.script}
          })();
        `;
      }

      const data = await window.webContents.executeJavaScript(scriptWithData);

      return {
        success: true,
        data,
        timestamp: new Date().toISOString(),
        actionId: writer.id,
        actionName: writer.name,
        scenarioId,
        sourceId,
        url
      };
    } catch (error: any) {
      return {
        success: false,
        error: error.message,
        timestamp: new Date().toISOString(),
        actionId: writer.id,
        actionName: writer.name,
        scenarioId,
        sourceId,
        url: window.webContents.getURL()
      };
    }
  }

  /**
   * Test a reader/writer script on a local HTML file
   */
  async testScript(
    window: BrowserWindow,
    script: string,
    htmlPath: string
  ): Promise<any> {
    // Load the test fixture
    await window.loadFile(htmlPath);
    
    // Execute the script
    const result = await window.webContents.executeJavaScript(script);
    return result;
  }
}

