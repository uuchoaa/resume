import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu", "selectedText", "hiddenInput", "option"]

  connect() {
    this.boundClickOutside = this.clickOutside.bind(this)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    document.addEventListener("click", this.boundClickOutside)
  }

  close() {
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.boundClickOutside)
  }

  selectOption(event) {
    const option = event.currentTarget
    const value = option.dataset.value
    const label = option.dataset.label

    // Atualiza valor e texto
    this.hiddenInputTarget.value = value
    this.selectedTextTarget.textContent = label

    // Fecha o menu
    this.close()

    // Se o select está dentro de um form, faz submit automático
    const form = this.element.closest('form')
    if (form) {
      form.requestSubmit()
    }
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
