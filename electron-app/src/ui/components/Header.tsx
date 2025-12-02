import React, { useState, useEffect } from 'react';
import { useElectron } from '../context/ElectronContext';
import { NavigationHistory } from './NavigationHistory';

export function Header() {
  const { url, source, scenario, navigateTo, navigateBack, navigateForward, reload, clearHistory, loadWelcome } = useElectron();
  const [urlInput, setUrlInput] = useState('');

  useEffect(() => {
    setUrlInput(url);
  }, [url]);

  const handleGo = () => {
    if (urlInput.trim()) {
      navigateTo(urlInput.trim());
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleGo();
    }
  };

  return (
    <div className="bg-white border-b border-gray-200 p-4">
      <h1 className="text-xl font-bold text-gray-800">Control Panel</h1>
      
      {/* Navigation Controls */}
      <div className="mt-3 flex gap-2">
        <button 
          onClick={loadWelcome}
          className="px-3 py-1 bg-indigo-500 hover:bg-indigo-600 text-white rounded text-sm" 
          title="Welcome Page"
        >
          🏠
        </button>
        <NavigationHistory />
        <button 
          onClick={navigateBack}
          className="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded text-sm" 
          title="Back"
        >
          ←
        </button>
        <button 
          onClick={navigateForward}
          className="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded text-sm" 
          title="Forward"
        >
          →
        </button>
        <button 
          onClick={reload}
          className="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded text-sm" 
          title="Reload"
        >
          ↻
        </button>
        <input 
          type="text" 
          value={urlInput}
          onChange={(e) => setUrlInput(e.target.value)}
          onKeyPress={handleKeyPress}
          placeholder="Enter URL..." 
          className="flex-1 px-3 py-1 border border-gray-300 rounded text-sm"
        />
        <button 
          onClick={handleGo}
          className="px-4 py-1 bg-blue-500 hover:bg-blue-600 text-white rounded text-sm"
        >
          Go
        </button>
        <div className="border-l border-gray-300 mx-1"></div>
        <button 
          onClick={clearHistory}
          className="px-3 py-1 bg-red-500 hover:bg-red-600 text-white rounded text-sm" 
          title="Clear History"
        >
          🗑️
        </button>
      </div>
      
      <div className="mt-2 text-sm text-gray-600">
        <div><strong>URL:</strong> <span className="font-mono text-xs">{url || '-'}</span></div>
        <div><strong>Source:</strong> <span>{source?.name || '-'}</span></div>
        <div><strong>Scenario:</strong> <span>{scenario?.name || '-'}</span></div>
      </div>
    </div>
  );
}

