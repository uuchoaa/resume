/**
 * Action Executor - Executes readers and writers by injecting scripts
 */

import { BrowserWindow } from 'electron';
import { Reader, Writer, ExecutionResult } from '../types';

export class ActionExecutor {
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
        // Get full page dimensions
        const dimensions = await window.webContents.executeJavaScript(`
          ({
            width: Math.max(
              document.documentElement.scrollWidth,
              document.body.scrollWidth,
              document.documentElement.offsetWidth,
              document.body.offsetWidth,
              document.documentElement.clientWidth
            ),
            height: Math.max(
              document.documentElement.scrollHeight,
              document.body.scrollHeight,
              document.documentElement.offsetHeight,
              document.body.offsetHeight,
              document.documentElement.clientHeight
            )
          })
        `);

        // Capture the entire page
        const image = await window.capturePage({
          x: 0,
          y: 0,
          width: dimensions.width,
          height: dimensions.height
        });

        // Convert to base64
        const base64 = image.toPNG().toString('base64');
        data = {
          format: 'png',
          base64: base64,
          width: dimensions.width,
          height: dimensions.height,
          dataUrl: `data:image/png;base64,${base64}`
        };
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

