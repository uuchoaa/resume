/**
 * Simple URL store to remember last visited URL
 */

import * as fs from 'fs';
import * as path from 'path';
import { app } from 'electron';

interface BookmarkEntry {
  url: string;
  title: string;
  timestamp: string;
}

interface StoreData {
  lastUrl?: string;
  lastVisited?: string;
  bookmarks?: BookmarkEntry[];
}

export class UrlStore {
  private filePath: string;
  private data: StoreData;

  constructor() {
    const userDataPath = app.getPath('userData');
    this.filePath = path.join(userDataPath, 'url-store.json');
    this.data = this.load();
  }

  private load(): StoreData {
    try {
      if (fs.existsSync(this.filePath)) {
        const content = fs.readFileSync(this.filePath, 'utf-8');
        return JSON.parse(content);
      }
    } catch (error) {
      console.error('Error loading URL store:', error);
    }
    return {};
  }

  private save(): void {
    try {
      fs.writeFileSync(this.filePath, JSON.stringify(this.data, null, 2));
    } catch (error) {
      console.error('Error saving URL store:', error);
    }
  }

  getLastUrl(): string | null {
    return this.data.lastUrl || null;
  }

  setLastUrl(url: string, title?: string): void {
    // Don't save local file URLs (welcome page)
    if (url.startsWith('file://')) {
      return;
    }
    
    this.data.lastUrl = url;
    this.data.lastVisited = new Date().toISOString();
    this.save();
  }
  
  // Bookmark management
  addBookmark(url: string, title: string): boolean {
    // Don't save local file URLs
    if (url.startsWith('file://')) {
      return false;
    }
    
    if (!this.data.bookmarks) {
      this.data.bookmarks = [];
    }
    
    // Check if already bookmarked
    if (this.data.bookmarks.some(b => b.url === url)) {
      return false; // Already exists
    }
    
    // Add to beginning
    this.data.bookmarks.unshift({
      url,
      title,
      timestamp: new Date().toISOString()
    });
    
    this.save();
    return true;
  }
  
  removeBookmark(url: string): boolean {
    if (!this.data.bookmarks) {
      return false;
    }
    
    const initialLength = this.data.bookmarks.length;
    this.data.bookmarks = this.data.bookmarks.filter(b => b.url !== url);
    
    if (this.data.bookmarks.length < initialLength) {
      this.save();
      return true;
    }
    return false;
  }
  
  getBookmarks(): BookmarkEntry[] {
    return this.data.bookmarks || [];
  }
  
  isBookmarked(url: string): boolean {
    return this.data.bookmarks?.some(b => b.url === url) || false;
  }

  clear(): void {
    this.data = {};
    this.save();
  }
}

