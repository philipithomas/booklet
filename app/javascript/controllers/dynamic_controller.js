import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["loading", "button", "arrow"];

  connect() {
    this.loadingTarget.classList.add("hidden");
    this.buttonTarget.disabled = false;
  }

displayLoading(event) {
  // Get the parent form of the button
  const parentForm = this.buttonTarget.closest('form');

  // Check if the event target (submitted form) is the same as the button's parent form
  if (event.target !== parentForm) {
    return; // Exit if they are not the same
  }

  // Rest of your logic
  this.loadingTarget.classList.remove("hidden");
  this.arrowTarget.classList.add("hidden");
  this.buttonTarget.disabled = true;
}
}
