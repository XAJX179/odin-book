import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = [ "nameField", "results" ]
  static values = { url: String }

  connect() {
  }

  fetchResults() {
    if(this.nameField == "") {
      this.reset()
      return
    }

    if(this.nameField == this.previousQuery) {
      return
    }
    this.previousQuery = this.nameField

    const url = new URL(this.urlValue)
    url.searchParams.append("name", this.nameField)

    this.abortPreviousFetchRequest()

    this.abortController = new AbortController()
    fetch(url, { signal: this.abortController.signal })
      .then(response => response.text())
      .then(html => {
        this.resultsTarget.innerHTML = html
      })
      .catch(() => {})
  }

  // private

  reset() {
    this.resultsTarget.innerHTML = ""
    this.nameFieldTarget.value = ""
    this.previousQuery = null
  }

  abortPreviousFetchRequest() {
    if(this.abortController) {
      this.abortController.abort()
    }
  }

  get nameField() {
    return this.nameFieldTarget.value
  }
}
