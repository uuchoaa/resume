import React, { useState, useEffect } from 'react';
import { useElectron } from '../context/ElectronContext';

export function DetailModal() {
  const { selectedRecord, setSelectedRecord, processors, executeProcessor } = useElectron();
  const [selectedProcessorId, setSelectedProcessorId] = useState('');

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        setSelectedRecord(null);
      }
    };

    if (selectedRecord) {
      document.addEventListener('keydown', handleEscape);
      return () => document.removeEventListener('keydown', handleEscape);
    }
  }, [selectedRecord, setSelectedRecord]);

  const handleApplyProcessor = async () => {
    if (!selectedRecord || !selectedProcessorId) return;
    
    const success = await executeProcessor(selectedRecord.id, selectedProcessorId);
    if (success) {
      // Record will be updated via onDataUpdated event
      setSelectedProcessorId('');
    }
  };

  if (!selectedRecord) return null;

  // Filter processors based on the dataType of the extracted data
  const dataType = selectedRecord.result.dataType;
  const compatibleProcessors = dataType 
    ? processors.filter(p => p.compatibleDataTypes && p.compatibleDataTypes.includes(dataType))
    : processors; // Show all if no dataType specified (backwards compatibility)

  const content = {
    result: selectedRecord.result,
    processed: selectedRecord.processed
  };

  const renderDataPreview = () => {
    const result = selectedRecord.result;
    
    // Image preview
    if (result.dataType === 'image' && result.success && result.data?.dataUrl) {
      return (
        <div className="mb-4">
          <h4 className="text-sm font-medium text-gray-700 mb-2">Image Preview:</h4>
          <img 
            src={result.data.dataUrl} 
            alt="Screenshot" 
            className="max-w-full border border-gray-300 rounded"
          />
          <p className="text-xs text-gray-500 mt-2">
            {result.data.width} × {result.data.height} pixels
          </p>
        </div>
      );
    }

    // Raw data
    return (
      <div className="mb-4">
        <h4 className="text-sm font-medium text-gray-700 mb-2">Raw Data:</h4>
        <pre className="bg-gray-100 p-4 rounded text-xs font-mono overflow-auto max-h-64">
          {JSON.stringify(result.data, null, 2)}
        </pre>
      </div>
    );
  };

  const renderProcessorResult = () => {
    if (!selectedRecord.processed) return null;

    const output = selectedRecord.processed.output;

    return (
      <div className="mb-4 p-4 bg-purple-50 border border-purple-200 rounded">
        <h4 className="text-sm font-medium text-purple-900 mb-2">
          ✓ Processed by {selectedRecord.processed.processorName}
        </h4>
        <div className="text-xs text-gray-600 mb-2">
          {new Date(selectedRecord.processed.timestamp).toLocaleString()}
        </div>
        
        {output.success ? (
          <div className="bg-white p-3 rounded border border-purple-100">
            {output.message && (
              <p className="text-sm text-green-700 mb-2">{output.message}</p>
            )}
            {output.filePath && (
              <p className="text-xs text-gray-600 mb-1">
                <strong>File:</strong> {output.filePath}
              </p>
            )}
            {output.fileName && (
              <p className="text-xs text-gray-600 mb-1">
                <strong>Name:</strong> {output.fileName}
              </p>
            )}
            {output.size && (
              <p className="text-xs text-gray-600 mb-1">
                <strong>Size:</strong> {(output.size / 1024).toFixed(2)} KB
              </p>
            )}
            {output.summary && (
              <pre className="text-xs text-gray-700 mt-2 bg-gray-50 p-2 rounded overflow-auto max-h-40">
                {JSON.stringify(output.summary, null, 2)}
              </pre>
            )}
          </div>
        ) : (
          <p className="text-sm text-red-700">Error: {output.error}</p>
        )}
      </div>
    );
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-lg p-6 w-3/4 h-3/4 flex flex-col">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold">{selectedRecord.result.actionName}</h3>
          <button 
            onClick={() => setSelectedRecord(null)}
            className="text-gray-500 hover:text-gray-700 text-2xl"
          >
            &times;
          </button>
        </div>
        
        {/* Processor Result */}
        {renderProcessorResult()}

        {/* Processors */}
        <div className="mb-4">
          <label className="text-sm font-medium text-gray-700">Apply Processor:</label>
          <div className="flex space-x-2 mt-2">
            <select 
              value={selectedProcessorId}
              onChange={(e) => setSelectedProcessorId(e.target.value)}
              className="flex-1 border border-gray-300 rounded p-2 text-sm"
            >
              <option value="">Select a processor...</option>
              {compatibleProcessors.map(p => (
                <option key={p.id} value={p.id}>
                  {p.name} - {p.description}
                </option>
              ))}
            </select>
            <button 
              onClick={handleApplyProcessor}
              disabled={!selectedProcessorId}
              className="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:bg-gray-300 disabled:cursor-not-allowed"
            >
              Apply
            </button>
          </div>
        </div>

        <div className="flex-1 overflow-auto">
          {renderDataPreview()}
          
          {/* Debug: Full JSON */}
          <details className="mt-2">
            <summary className="text-xs text-gray-500 cursor-pointer hover:text-gray-700">
              Show raw JSON data
            </summary>
            <pre className="bg-gray-100 p-4 rounded text-xs font-mono overflow-auto mt-2">
              {JSON.stringify(content, null, 2)}
            </pre>
          </details>
        </div>
      </div>
    </div>
  );
}

