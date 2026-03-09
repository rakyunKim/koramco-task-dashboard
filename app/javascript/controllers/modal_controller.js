import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "panel"]

  connect() {
    // Prevent body scroll when modal is open
    document.body.style.overflow = "hidden"
    requestAnimationFrame(() => {
      this.backdropTarget.classList.remove("opacity-0")
      this.panelTarget.classList.remove("translate-y-full", "lg:translate-y-full", "lg:scale-95", "lg:opacity-0")
    })
  }

  close() {
    this.backdropTarget.classList.add("opacity-0")
    this.panelTarget.classList.add("translate-y-full", "lg:translate-y-full", "lg:scale-95", "lg:opacity-0")
    setTimeout(() => {
      document.body.style.overflow = ""
      // Remove the turbo frame content
      const frame = document.getElementById("modal")
      if (frame) frame.innerHTML = ""
    }, 200)
  }

  backdropClose(e) {
    if (e.target === this.backdropTarget) {
      this.close()
    }
  }

  // Close on escape key
  closeWithKeyboard(e) {
    if (e.key === "Escape") this.close()
  }
}
