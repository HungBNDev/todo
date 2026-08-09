import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    userId: String
  }

  connect() {
    const metaTag = document.querySelector('meta[name="current-user-id"]')
    if (!metaTag) {
      this.element.classList.add('author-other')
      return
    }

    const currentUserId = metaTag.content

    if (currentUserId === this.userIdValue) {
      this.element.classList.add('author-self')
    } else {
      this.element.classList.add('author-other')
    }
  }
}
