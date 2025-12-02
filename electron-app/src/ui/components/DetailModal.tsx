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
    ? processors.filter(p => p.compatibleDataTypes.includes(dataType))
    : processors; // Show all if no dataType specified (backwards compatibility)

  const content = {
    result: selectedRecord.result,
    processed: selectedRecord.processed
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
          <pre className="bg-gray-100 p-4 rounded text-xs font-mono overflow-auto h-full">
            {JSON.stringify(content, null, 2)}
          </pre>
        </div>
      </div>
    </div>
  );
}

