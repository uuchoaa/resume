/**
 * Source Manager - Loads and manages all sources
 */

import { Source } from '../types';

export class SourceManager {
  private sources: Map<string, Source> = new Map();

  /**
   * Register a source
   */
  register(source: Source): void {
    this.sources.set(source.id, source);
  }

  /**
   * Get a source by ID
   */
  getSource(id: string): Source | undefined {
    return this.sources.get(id);
  }

  /**
   * Get all registered sources
   */
  getAllSources(): Source[] {
    return Array.from(this.sources.values());
  }

  /**
   * Find source by domain
   * Returns the most specific source (domain-specific over universal)
   */
  findSourceByDomain(hostname: string): Source | undefined {
    let universalSource: Source | undefined;

    // First pass: look for domain-specific sources and track universal source
    for (const source of this.sources.values()) {
      // Empty domains array means universal (applies to all domains)
      if (source.domains.length === 0) {
        universalSource = source;
        continue;
      }

      // Check if this source matches the hostname
      if (source.domains.some(domain => hostname.includes(domain))) {
        return source; // Return specific match immediately
      }
    }

    // If no specific source found, return universal source (if exists)
    return universalSource;
  }

  /**
   * Get total sources count
   */
  count(): number {
    return this.sources.size;
  }
}

