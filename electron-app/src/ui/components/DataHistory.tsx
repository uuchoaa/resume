import React from 'react';
import { useElectron } from '../context/ElectronContext';

export function DataHistory() {
  const { records, clearRecords, setSelectedRecord } = useElectron();

  const handleRecordClick = (recordId: string) => {
    const record = records.find(r => r.id === recordId);
    if (record) {
      setSelectedRecord(record);
    }
  };

  const renderPreview = (record: any) => {
    const result = record.result;
    const dataType = result.dataType;

    // Image preview
    if (dataType === 'image' && result.success && result.data?.dataUrl) {
      return (
        <div className="mt-2">
          <img 
            src={result.data.dataUrl} 
            alt="Screenshot preview" 
            className="max-w-full h-20 object-contain border border-gray-300 rounded"
          />
        </div>
      );
    }

    // Text/JSON preview
    if ((dataType === 'text' || dataType === 'json') && result.success && result.data) {
      const preview = typeof result.data === 'string' 
        ? result.data.substring(0, 100)
        : JSON.stringify(result.data).substring(0, 100);
      return (
        <div className="mt-1 text-xs text-gray-500 truncate">
          {preview}...
        </div>
      );
    }

    return null;
  };

  // Sort records by timestamp, most recent first
  const sortedRecords = [...records].sort((a, b) => {
    return new Date(b.result.timestamp).getTime() - new Date(a.result.timestamp).getTime();
  });

  return (
    <div className="bg-white rounded-lg shadow p-4">
      <div className="flex justify-between items-center mb-3">
        <h2 className="text-lg font-semibold">Data History</h2>
        <button 
          onClick={clearRecords}
          className="text-sm px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600"
        >
          Clear
        </button>
      </div>
      <div className="space-y-2">
        {sortedRecords.length === 0 ? (
          <p className="text-sm text-gray-500">No data extracted yet</p>
        ) : (
          sortedRecords.map(record => {
            const result = record.result;
            const statusColor = result.success ? 'green' : 'red';
            const time = new Date(result.timestamp).toLocaleTimeString();
            
            return (
              <div 
                key={record.id}
                onClick={() => handleRecordClick(record.id)}
                className="border border-gray-200 rounded p-3 hover:bg-gray-50 cursor-pointer"
              >
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <div className="font-medium text-sm">{result.actionName}</div>
                    <div className="text-xs text-gray-600">{result.sourceId} → {result.scenarioId}</div>
                    {record.processed && (
                      <div className="text-xs text-purple-600 mt-1">
                        ✓ Processed by {record.processed.processorName}
                      </div>
                    )}
                    {renderPreview(record)}
                  </div>
                  <div className="text-right flex-shrink-0 ml-2">
                    <span className={`inline-block px-2 py-1 text-xs rounded bg-${statusColor}-100 text-${statusColor}-700`}>
                      {result.success ? 'Success' : 'Failed'}
                    </span>
                    <div className="text-xs text-gray-500 mt-1">{time}</div>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}

