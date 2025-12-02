/**
 * Scenario Detector - Detects active scenario based on URL
 */

import { Source, Scenario } from '../types';

export class ScenarioDetector {
  /**
   * Detect scenario from URL within a source
   */
  detect(source: Source, url: string): Scenario | null {
    for (const scenario of source.scenarios) {
      if (scenario.urlPattern.test(url)) {
        return scenario;
      }
    }
    return null;
  }

  /**
   * Get all scenarios for a source
   */
  getScenariosForSource(source: Source): Scenario[] {
    return source.scenarios;
  }

  /**
   * Find scenario by ID within a source
   */
  findScenarioById(source: Source, scenarioId: string): Scenario | undefined {
    return source.scenarios.find(s => s.id === scenarioId);
  }
}

