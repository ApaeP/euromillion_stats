import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  refresh() {
    this.containerTarget.style.opacity = "0.5"

    window.location.reload()
  }
}
