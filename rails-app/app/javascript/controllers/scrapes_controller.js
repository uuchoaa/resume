import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["summarizeBtn"]
  
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
    
    // Store last scraped data
    this.lastScrapedData = null
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
          
          // Store for summarization and display
          if (result && result.scrapeData) {
            this.lastScrapedData = result.scrapeData
            this.displayResults(result.scrapeData)
          }
        })
        .catch(error => {
          console.error("Scrape error:", error)
          this.showError(error.message)
        })
    } else {
      this.showError("Not running in Electron app")
    }
  }

  summarize(event) {
    event.preventDefault()
    console.log("🤖 Summarize button clicked")
    
    if (!this.lastScrapedData) {
      alert("Please scrape a conversation first!")
      return
    }
    
    // Show loading state
    const btn = event.currentTarget
    const originalText = btn.textContent
    btn.disabled = true
    btn.textContent = "Summarizing..."
    
    // Send to Rails for summarization
    fetch('/deals/summarize', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(this.lastScrapedData)
    })
    .then(response => response.json())
    .then(data => {
      console.log("Summary received:", data)
      this.displaySummary(data.summary)
    })
    .catch(error => {
      console.error("Summarize error:", error)
      this.showError("Failed to generate summary: " + error.message)
    })
    .finally(() => {
      btn.disabled = false
      btn.textContent = originalText
    })
  }

  generateResponses(event) {
    event.preventDefault()
    console.log("💬 Generate Responses button clicked")
    
    if (!this.lastScrapedData) {
      alert("Please scrape a conversation first!")
      return
    }
    
    // Show loading state
    const btn = event.currentTarget
    const originalText = btn.textContent
    btn.disabled = true
    btn.textContent = "Generating..."
    
    // Send to Rails for response generation
    fetch('/deals/generate_responses', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(this.lastScrapedData)
    })
    .then(response => response.json())
    .then(data => {
      console.log("Responses received:", data)
      this.displayResponseOptions(data.responses)
    })
    .catch(error => {
      console.error("Generate responses error:", error)
      this.showError("Failed to generate responses: " + error.message)
    })
    .finally(() => {
      btn.disabled = false
      btn.textContent = originalText
    })
  }

  displayResults(data) {
    const container = document.getElementById("results-container")
    const emptyState = document.getElementById("empty-state")
    const content = document.getElementById("results-content")

    // Hide empty state and show results
    emptyState.classList.add("hidden")
    container.classList.remove("hidden")

    content.innerHTML = `
      <div class="border-l-4 border-green-400 bg-green-50 p-4">
        <code class="text-xs font-mono bg-white p-3 mt-2 whitespace-pre-wrap">${JSON.stringify(data, null, 2)}</code>
      </div>
    `
  }

  displaySummary(summary) {
    const container = document.getElementById("results-container")
    const content = document.getElementById("results-content")
    
    // Add summary to top of results
    const summaryHtml = `
      <div class="border-l-4 border-blue-400 bg-blue-50 p-4 mb-4">
        <h4 class="text-sm font-medium text-blue-800 mb-2">🤖 AI Summary</h4>
        <p class="text-sm text-blue-900 whitespace-pre-wrap">${this.escapeHtml(summary)}</p>
      </div>
    `
    
    content.insertAdjacentHTML('afterbegin', summaryHtml)
  }

  displayResponseOptions(responses) {
    const container = document.getElementById("results-container")
    const content = document.getElementById("results-content")
    
    // Add response options to top of results
    const optionsHtml = `
      <div class="border-l-4 border-purple-400 bg-purple-50 p-4 mb-4">
        <h4 class="text-sm font-medium text-purple-800 mb-3">💬 AI Response Suggestions</h4>
        <div class="space-y-2">
          <button 
            data-action="click->scrapes#selectResponse"
            data-response="${this.escapeHtml(responses.affirmative)}"
            class="w-full text-left p-3 bg-white border border-green-300 rounded-lg hover:bg-green-50 hover:border-green-400 transition-colors">
            <div class="font-semibold text-green-700 text-xs mb-1">✅ AFFIRMATIVE</div>
            <div class="text-sm text-gray-800">${this.escapeHtml(responses.affirmative)}</div>
          </button>
          
          <button 
            data-action="click->scrapes#selectResponse"
            data-response="${this.escapeHtml(responses.negative)}"
            class="w-full text-left p-3 bg-white border border-red-300 rounded-lg hover:bg-red-50 hover:border-red-400 transition-colors">
            <div class="font-semibold text-red-700 text-xs mb-1">❌ NEGATIVE</div>
            <div class="text-sm text-gray-800">${this.escapeHtml(responses.negative)}</div>
          </button>
        </div>
      </div>
    `
    
    content.insertAdjacentHTML('afterbegin', optionsHtml)
  }

  selectResponse(event) {
    const responseText = event.currentTarget.getAttribute('data-response')
    console.log("✉️ Selected response:", responseText)
    
    // Check if we're in Electron
    if (window.electronAPI && window.electronAPI.injectResponse) {
      window.electronAPI.injectResponse(responseText)
        .then(() => {
          console.log("✅ Response injected into W1")
          alert("✅ Response injected! Check W1 textarea")
        })
        .catch(error => {
          console.error("Inject error:", error)
          alert("❌ Failed to inject: " + error.message)
        })
    } else {
      alert("Not running in Electron app or API not available")
    }
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

