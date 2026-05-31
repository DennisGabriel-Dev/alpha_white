import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form"]
  static values = {
    expiresAt: String
  }

  connect() {
    this.questionStarts = {}
    if (this.hasFormTarget) {
      this.formTarget.querySelectorAll("[data-question-id]").forEach((el) => {
        this.questionStarts[el.dataset.questionId] = Date.now()
      })
      this.formTarget.addEventListener("submit", this.beforeSubmit)
    }
    this.tick()
    this.interval = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.interval)
    if (this.hasFormTarget) {
      this.formTarget.removeEventListener("submit", this.beforeSubmit)
    }
  }

  beforeSubmit = () => {
    Object.entries(this.questionStarts).forEach(([questionId, startedAt]) => {
      const seconds = Math.max(1, Math.round((Date.now() - startedAt) / 1000))
      let input = this.formTarget.querySelector(`input[name="time_spent[${questionId}]"]`)
      if (!input) {
        input = document.createElement("input")
        input.type = "hidden"
        input.name = `time_spent[${questionId}]`
        this.formTarget.appendChild(input)
      }
      input.value = seconds
    })
  }

  tick() {
    const expiresAt = new Date(this.expiresAtValue)
    const remaining = Math.max(0, Math.floor((expiresAt - Date.now()) / 1000))

    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = this.formatTime(remaining)
      this.displayTarget.classList.toggle("text-red-600", remaining <= 60)
      this.displayTarget.classList.toggle("font-bold", remaining <= 60)
    }

    if (remaining <= 0) {
      clearInterval(this.interval)
      if (this.hasFormTarget) {
        this.beforeSubmit()
        this.formTarget.requestSubmit()
      }
    }
  }

  formatTime(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    return `${minutes}:${String(seconds).padStart(2, "0")}`
  }
}
