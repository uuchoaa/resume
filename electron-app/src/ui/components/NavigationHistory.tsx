import React, { useState, useEffect } from 'react';
import type { BookmarkEntry } from '../types';

export function NavigationHistory() {
  const [bookmarks, setBookmarks] = useState<BookmarkEntry[]>([]);
  const [isOpen, setIsOpen] = useState(false);
  const [isBookmarked, setIsBookmarked] = useState(false);

  useEffect(() => {
    loadBookmarks();
    checkBookmarked();
  }, []);

  const loadBookmarks = async () => {
    if (!window.electronAPI) return;
    const entries = await window.electronAPI.getBookmarks();
    setBookmarks(entries);
  };

  const checkBookmarked = async () => {
    if (!window.electronAPI) return;
    const bookmarked = await window.electronAPI.isBookmarked();
    setIsBookmarked(bookmarked);
  };

  const handleAddBookmark = async () => {
    if (!window.electronAPI) return;
    const result = await window.electronAPI.addBookmark();
    if (result.success) {
      await loadBookmarks();
      await checkBookmarked();
      alert('✅ Bookmark adicionado!');
    } else {
      alert('⚠️ ' + result.error);
    }
  };

  const handleRemoveBookmark = async (url: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (!window.electronAPI) return;
    if (confirm('Remover este bookmark?')) {
      await window.electronAPI.removeBookmark(url);
      await loadBookmarks();
      await checkBookmarked();
    }
  };

  const handleNavigate = async (url: string) => {
    if (!window.electronAPI) return;
    await window.electronAPI.navigateToBookmark(url);
    setIsOpen(false);
    // Reload bookmarked state after navigation
    setTimeout(() => checkBookmarked(), 500);
  };

  const formatDate = (timestamp: string) => {
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    
    if (diffMins < 1) return 'Agora';
    if (diffMins < 60) return `${diffMins}m atrás`;
    
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours}h atrás`;
    
    const diffDays = Math.floor(diffHours / 24);
    if (diffDays === 1) return 'Ontem';
    if (diffDays < 7) return `${diffDays}d atrás`;
    
    return date.toLocaleDateString();
  };

  return (
    <div className="relative flex gap-2">
      {/* Add Bookmark Button */}
      <button
        onClick={handleAddBookmark}
        className={`px-3 py-1 rounded text-sm ${
          isBookmarked 
            ? 'bg-yellow-500 text-white hover:bg-yellow-600' 
            : 'bg-gray-200 hover:bg-gray-300'
        }`}
        title={isBookmarked ? 'Página já marcada' : 'Adicionar bookmark'}
      >
        {isBookmarked ? '⭐' : '☆'}
      </button>

      {/* Bookmarks List */}
      {bookmarks.length > 0 && (
        <button
          onClick={() => setIsOpen(!isOpen)}
          className="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded text-sm flex items-center gap-1"
          title="Ver bookmarks"
        >
          📚 Bookmarks
          <span className="text-xs text-gray-600">({bookmarks.length})</span>
        </button>
      )}

      {isOpen && (
        <>
          {/* Backdrop */}
          <div 
            className="fixed inset-0 z-10" 
            onClick={() => setIsOpen(false)}
          />
          
          {/* Dropdown */}
          <div className="absolute top-full right-0 mt-1 w-96 bg-white border border-gray-300 rounded-lg shadow-lg z-20 max-h-96 overflow-y-auto">
            <div className="p-2 border-b border-gray-200 bg-gray-50">
              <h3 className="text-sm font-semibold">Meus Bookmarks</h3>
            </div>
            <div className="py-1">
              {bookmarks.map((entry, index) => (
                <div
                  key={index}
                  className="w-full text-left px-3 py-2 hover:bg-gray-100 border-b border-gray-100 last:border-0 transition-colors group"
                >
                  <div className="flex items-start justify-between gap-2">
                    <div 
                      className="flex-1 min-w-0 cursor-pointer"
                      onClick={() => handleNavigate(entry.url)}
                    >
                      <div className="text-sm font-medium text-gray-900 truncate">
                        {entry.title || 'Sem título'}
                      </div>
                      <div className="text-xs text-gray-500 truncate">
                        {entry.url}
                      </div>
                      <div className="text-xs text-gray-400 mt-1">
                        {formatDate(entry.timestamp)}
                      </div>
                    </div>
                    <button
                      onClick={(e) => handleRemoveBookmark(entry.url, e)}
                      className="opacity-0 group-hover:opacity-100 text-red-500 hover:text-red-700 text-xs px-2 py-1 transition-opacity"
                      title="Remover bookmark"
                    >
                      ✕
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </>
      )}
    </div>
  );
}

