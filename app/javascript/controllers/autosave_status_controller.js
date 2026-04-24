import { Controller } from "@hotwired/stimulus";
import { useTransition } from "stimulus-use";

export default class extends Controller {
  static targets = ["saved", "error"];

  connect() {
    useTransition(this, {
      element: this.savedTarget,
    });
  }

  saving() {
    this.hide(this.errorTarget);
  }

  completed(e) {
    if (e.detail.success) {
      this.displaySuccess();
    } else {
      this.displayError();
    }
  }

  displaySuccess() {
    this.enter();
    const self = this;
    setTimeout(() => {
      self.leave();
    }, 1000);
  }

  displayError() {
    this.show(this.errorTarget);
  }

  show(target) {
    target.classList.remove("hidden");
  }
  hide(target) {
    target.classList.add("hidden");
  }
}
