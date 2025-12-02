import React, { useState, useEffect } from 'react';
import { useElectron } from '../context/ElectronContext';

interface WriterModalProps {
  isOpen: boolean;
  onClose: () => void;
  writerId: string;
  writerName: string;
}

export function WriterModal({ isOpen, onClose, writerId, writerName }: WriterModalProps) {
  const { executeWriter } = useElectron();
  const [inputData, setInputData] = useState('');

  useEffect(() => {
    if (isOpen) {
      setInputData('');
    }
  }, [isOpen]);

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      return () => document.removeEventListener('keydown', handleEscape);
    }
  }, [isOpen, onClose]);

  const handleSubmit = async () => {
    const data = inputData.trim();
    if (data) {
      await executeWriter(writerId, data);
      onClose();
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-lg p-6 w-96">
        <h3 className="text-lg font-semibold mb-4">{writerName}</h3>
        <textarea 
          value={inputData}
          onChange={(e) => setInputData(e.target.value)}
          className="w-full border border-gray-300 rounded p-2 h-32 font-mono text-sm" 
          placeholder="Enter input data..."
          autoFocus
        />
        <div className="flex justify-end space-x-2 mt-4">
          <button 
            onClick={onClose}
            className="px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400"
          >
            Cancel
          </button>
          <button 
            onClick={handleSubmit}
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            Execute
          </button>
        </div>
      </div>
    </div>
  );
}

