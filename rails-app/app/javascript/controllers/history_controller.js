import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="history"
export default class extends Controller {
  back(event) {
    event.preventDefault()
    window.history.back()
  }
}
