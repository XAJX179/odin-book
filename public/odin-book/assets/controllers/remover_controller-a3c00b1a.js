import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="remover"
export default class extends Controller {
  connect() {
    console.log(this.element)
  }

  remove() {
    console.log(this.element)
    this.element.remove()
  }
}
