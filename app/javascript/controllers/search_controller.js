import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["searchField", "results"]
  static values = { url: String }

  connect() {
    console.log(
      this.searchFieldTarget.name
    )
  }

  fetchResults() {
    if (this.searchField == "") {
      this.reset()
      return
    }

    if (this.searchField == this.previousQuery) {
      return
    }
    this.previousQuery = this.searchField

    const url = new URL(this.urlValue)
    url.searchParams.append(this.searchFieldTarget.name, this.searchField)

    this.abortPreviousFetchRequest()

    this.abortController = new AbortController()
    fetch(url, { signal: this.abortController.signal })
      .then(response => response.text())
      .then(html => {
        this.resultsTarget.innerHTML = html
      })
      .catch(() => { })
  }

  // private

  reset() {
    this.resultsTarget.innerHTML = ""
    this.searchFieldTarget.value = ""
    this.previousQuery = null
  }

  abortPreviousFetchRequest() {
    if (this.abortController) {
      this.abortController.abort()
    }
  }

  get searchField() {
    return this.searchFieldTarget.value
  }
}
