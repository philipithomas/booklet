import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const vw = Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0);

    if (vw < 768) { // same tab on mobile
      return;
    }

    this.element.querySelectorAll('a').forEach(function(link) {
      if (link.host !== window.location.host) {
        link.target = "_blank";
        link.rel = "noopener";
      }
    })
  }
}