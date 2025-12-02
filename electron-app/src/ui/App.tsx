import React from 'react';
import { ElectronProvider } from './context/ElectronContext';
import { Header } from './components/Header';
import { ActionsPanel } from './components/ActionsPanel';
import { DataHistory } from './components/DataHistory';
import { DetailModal } from './components/DetailModal';

function AppContent() {
  return (
    <div className="flex flex-col h-screen bg-gray-100">
      <Header />
      
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <ActionsPanel />
        <DataHistory />
      </div>

      <DetailModal />
    </div>
  );
}

export function App() {
  return (
    <ElectronProvider>
      <AppContent />
    </ElectronProvider>
  );
}

