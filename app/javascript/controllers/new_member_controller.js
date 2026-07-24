import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["consent", "sendWelcome", "button", "directAddLimit"];

  connect() {
    this.toggleSendWelcome();
  }

  toggleSendWelcome() {
    if (this.consentTarget.checked) {
      this.sendWelcomeTarget.classList.remove("hidden");
      this.directAddLimitTarget.classList.remove("hidden");
      this.buttonTarget.querySelector(".btn-text").textContent =
        this.buttonTarget.dataset.addLabel;
      if (this.buttonTarget.dataset.canDirectAdd === "false") {
        this.buttonTarget.disabled = true;
      }
    } else {
      this.sendWelcomeTarget.classList.add("hidden");
      this.directAddLimitTarget.classList.add("hidden");
      this.buttonTarget.querySelector(".btn-text").textContent =
        this.buttonTarget.dataset.inviteLabel;
      this.buttonTarget.disabled = false;
    }
  }
}
