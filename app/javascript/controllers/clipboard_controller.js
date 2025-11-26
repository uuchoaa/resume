import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  copy(event) {
    const button = event.currentTarget
    const code = this.sourceTarget.textContent

    navigator.clipboard.writeText(code).then(() => {
      // Salva texto original
      const originalText = button.textContent

      // Mostra feedback
      button.textContent = "✓ Copied!"
      button.classList.add("text-green-400")

      // Volta ao normal após 2 segundos
      setTimeout(() => {
        button.textContent = originalText
        button.classList.remove("text-green-400")
      }, 2000)
    }).catch(err => {
      console.error("Failed to copy:", err)
    })
  }
}
