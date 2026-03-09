import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { taskId: Number }

  toggle() {
    const token = document.querySelector('meta[name="csrf-token"]').content

    fetch(`/tasks/${this.taskIdValue}/toggle`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": token,
        "Accept": "text/vnd.turbo-stream.html"
      }
    }).then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
      })
  }
}
