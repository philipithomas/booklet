import { Controller } from "@hotwired/stimulus";
import mediumZoom from "medium-zoom";

export default class extends Controller {
  connect() {
    this.zoom = mediumZoom(this.element.querySelectorAll("img:not(.no-zoom)"), {
      background: "#222222",
    });
  }

  disconnect() {
    if (this.zoom) {
      this.zoom.detach();
    }
  }
}
