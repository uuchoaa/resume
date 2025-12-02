import React, { useState } from 'react';
import { useElectron } from '../context/ElectronContext';
import { WriterModal } from './WriterModal';

export function ActionsPanel() {
  const { scenario, executeReader } = useElectron();
  const [writerModalOpen, setWriterModalOpen] = useState(false);
  const [selectedWriter, setSelectedWriter] = useState<{ id: string; name: string } | null>(null);

  const handleReaderClick = (readerId: string) => {
    executeReader(readerId);
  };

  const handleWriterClick = (writerId: string, writerName: string) => {
    setSelectedWriter({ id: writerId, name: writerName });
    setWriterModalOpen(true);
  };

  const readers = scenario?.readers || [];
  const writers = scenario?.writers || [];

  return (
    <>
      <div className="bg-white rounded-lg shadow p-4">
        <h2 className="text-lg font-semibold mb-3">Actions</h2>
        
        {/* Readers */}
        <div className="mb-4">
          <h3 className="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
            <span className="text-blue-600">📖</span> Readers
          </h3>
          <div className="space-y-2">
            {readers.length > 0 ? (
              readers.map((reader) => (
                <button 
                  key={reader.id}
                  onClick={() => handleReaderClick(reader.id)}
                  className="group w-full text-left px-4 py-3 bg-gradient-to-r from-blue-50 to-blue-100 hover:from-blue-100 hover:to-blue-200 border-2 border-blue-300 hover:border-blue-400 rounded-lg text-sm transition-all duration-200 shadow-sm hover:shadow-md transform hover:scale-[1.02] cursor-pointer"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <div className="font-semibold text-blue-900 group-hover:text-blue-950">{reader.name}</div>
                      <div className="text-xs text-blue-700 mt-1">{reader.description}</div>
                    </div>
                    <svg className="w-5 h-5 text-blue-600 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                    </svg>
                  </div>
                </button>
              ))
            ) : (
              <p className="text-sm text-gray-500 italic">No readers available for current page</p>
            )}
          </div>
        </div>

        {/* Writers */}
        <div>
          <h3 className="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
            <span className="text-green-600">✏️</span> Writers
          </h3>
          <div className="space-y-2">
            {writers.length > 0 ? (
              writers.map((writer) => (
                <button 
                  key={writer.id}
                  onClick={() => handleWriterClick(writer.id, writer.name)}
                  className="group w-full text-left px-4 py-3 bg-gradient-to-r from-green-50 to-green-100 hover:from-green-100 hover:to-green-200 border-2 border-green-300 hover:border-green-400 rounded-lg text-sm transition-all duration-200 shadow-sm hover:shadow-md transform hover:scale-[1.02] cursor-pointer"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <div className="font-semibold text-green-900 group-hover:text-green-950">{writer.name}</div>
                      <div className="text-xs text-green-700 mt-1">{writer.description}</div>
                    </div>
                    <svg className="w-5 h-5 text-green-600 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                    </svg>
                  </div>
                </button>
              ))
            ) : (
              <p className="text-sm text-gray-500 italic">No writers available for current page</p>
            )}
          </div>
        </div>
      </div>

      {selectedWriter && (
        <WriterModal 
          isOpen={writerModalOpen}
          onClose={() => {
            setWriterModalOpen(false);
            setSelectedWriter(null);
          }}
          writerId={selectedWriter.id}
          writerName={selectedWriter.name}
        />
      )}
    </>
  );
}

