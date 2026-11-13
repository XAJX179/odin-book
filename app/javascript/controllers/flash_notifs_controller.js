import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="flash-notifs"
export default class extends Controller {
  connect() {
    console.log(this.element);
    this.timerId = setTimeout(() => {
      this.element.remove();
    }, 8000);
  }

  disconnect() {
    clearTimeout(this.timerId);
  }
}
