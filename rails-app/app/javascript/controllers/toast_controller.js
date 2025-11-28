import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  static values = {
    type: String
  }

  connect() {
    // Start hidden (slide from right)
    this.element.style.transform = "translateX(100%)"
    this.element.style.opacity = "0"
    
    // Animate in after a tiny delay
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.show()
      })
    })

    // Auto-dismiss after 5 seconds
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  show() {
    this.element.style.transform = "translateX(0)"
    this.element.style.opacity = "1"
  }

  dismiss() {
    // Clear timeout if manually dismissed
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Animate out
    this.element.style.transform = "translateX(100%)"
    this.element.style.opacity = "0"

    // Remove from DOM after animation completes
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}
