import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  connect() {
    console.log("✅ Scrapes controller connected!")
    console.log("Controller element:", this.element)
    
    // Create consumer directly here
    const consumer = createConsumer()
    
    // Subscribe to ActionCable channel
    this.channel = consumer.subscriptions.create("ScrapesChannel", {
      connected: () => {
        console.log("✅ Connected to ScrapesChannel")
      },

      disconnected: () => {
        console.log("❌ Disconnected from ScrapesChannel")
      },

      received: (data) => {
        console.log("📡 Received data:", data)
        this.displayResults(data)
      }
    })
  }

  disconnect() {
    if (this.channel) {
      this.channel.unsubscribe()
    }
  }

  scrape(event) {
    event.preventDefault()
    console.log("🔍 Scrape button clicked")
    
    // Check if we're in Electron
    if (window.electronAPI) {
      window.electronAPI.scrapeW1()
        .then(result => {
          console.log("Scrape initiated:", result)
        })
        .catch(error => {
          console.error("Scrape error:", error)
          this.showError(error.message)
        })
    } else {
      this.showError("Not running in Electron app")
    }
  }

  displayResults(data) {
    const container = document.getElementById("results-container")
    const emptyState = document.getElementById("empty-state")
    const content = document.getElementById("results-content")

    // Hide empty state and show results
    emptyState.classList.add("hidden")
    container.classList.remove("hidden")

    // Create results HTML
    content.innerHTML = `
      <div class="border-l-4 border-green-400 bg-green-50 p-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3 flex-1">
            <h4 class="text-sm font-medium text-green-800">Scrape Successful</h4>
            <div class="mt-2 text-sm text-green-700">
              <p class="font-mono bg-white p-3 rounded border border-green-200 mt-2">
                ${this.escapeHtml(data.text)}
              </p>
              <div class="mt-3 space-y-1 text-xs">
                <p><strong>Total Paragraphs:</strong> ${data.total_paragraphs || data.totalParagraphs}</p>
                <p><strong>Timestamp:</strong> ${new Date(data.timestamp).toLocaleString()}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    `
  }

  showError(message) {
    const container = document.getElementById("results-container")
    const emptyState = document.getElementById("empty-state")
    const content = document.getElementById("results-content")

    emptyState.classList.add("hidden")
    container.classList.remove("hidden")

    content.innerHTML = `
      <div class="border-l-4 border-red-400 bg-red-50 p-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <h4 class="text-sm font-medium text-red-800">Error</h4>
            <p class="mt-1 text-sm text-red-700">${this.escapeHtml(message)}</p>
          </div>
        </div>
      </div>
    `
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}

