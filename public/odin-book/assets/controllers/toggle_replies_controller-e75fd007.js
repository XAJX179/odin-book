import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-replies"
export default class extends Controller {
  static classes = ["hidden", "showToggle"]
  static targets = ["replies"]

  connect() {
    console.log("Connected Hide Replies")
    console.log(this.element)
  }

  hide(event) {
    this.repliesTarget.classList.add(this.hiddenClass)

    let showReply = document.createElement('a');

    let id = event.target.id

    showReply.setAttribute("id", id)
    showReply.setAttribute("data-action", "click->toggle-replies#show")
    showReply.classList.add(this.showToggleClass)
    showReply.innerText = "Show Replies"

    event.target.replaceWith(showReply)
  }

  show(event) {
    this.repliesTarget.classList.remove(this.hiddenClass)

    let hideReply = document.createElement('button');

    let id = event.target.id

    hideReply.setAttribute("id", id)
    hideReply.setAttribute("data-action", "click->toggle-replies#hide")
    hideReply.classList.add(this.showToggleClass)
    hideReply.innerText = "Hide Replies"

    console.log(hideReply)
    event.target.replaceWith(hideReply)
  }
}
