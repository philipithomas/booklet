import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "background", "input"];

  connect() {
    this.toggleClass = "hidden";
    this.containerTarget.classList.add(this.toggleClass);
    this.keyUpListener = (event) => {
      if (event.key === "Escape") {
        this.close(event);
      }
    };
  }

  open(event) {
    event.preventDefault();
    this.lockScroll();
    this.containerTarget.classList.remove(this.toggleClass);
    window.addEventListener("keyup", this.keyUpListener);
    this.inputTarget.focus();
  }

  close(event) {
    if (event) {
      event.preventDefault();
    }
    this.unlockScroll();
    this.containerTarget.classList.add(this.toggleClass);
    window.removeEventListener("keyup", this.keyUpListener);
  }

  handleSubmit(event) {
    if (!this.inputTarget.value.trim()) {
      event.preventDefault();
      this.close(event);
    }
  }

  closeWithKeyboard(e) {
    if (
      e.keyCode === 27 &&
      !this.containerTarget.classList.contains(this.toggleClass)
    ) {
      this.close(e);
    }
  }

  closeBackground(event) {
    if (
      (event.target === this.containerTarget) ||
      (event.target === this.backgroundTarget)
    ) {
      this.close(event);
    }
  }

  lockScroll() {
    // Add right padding to the body so the page doesn't shift
    // when we disable scrolling
    const scrollbarWidth = window.innerWidth -
      document.documentElement.clientWidth;
    document.body.style.paddingRight = `${scrollbarWidth}px`;

    // Add classes to body to fix its position
    document.body.classList.add("fixed", "inset-x-0", "overflow-hidden");

    if (this.restoreScrollValue) {
      // Save the scroll position
      this.saveScrollPosition();

      // Add negative top position in order for body to stay in place
      document.body.style.top = `-${this.scrollPosition}px`;
    }
  }

  unlockScroll() {
    // Remove tweaks for scrollbar
    document.body.style.paddingRight = null;

    // Remove classes from body to unfix position
    document.body.classList.remove("fixed", "inset-x-0", "overflow-hidden");

    // Restore the scroll position of the body before it got locked
    if (this.restoreScrollValue) {
      this.restoreScrollPosition();

      // Remove the negative top inline style from body
      document.body.style.top = null;
    }
  }

  saveScrollPosition() {
    this.scrollPosition = window.pageYOffset || document.body.scrollTop;
  }

  restoreScrollPosition() {
    if (this.scrollPosition === undefined) return;

    document.documentElement.scrollTop = this.scrollPosition;
  }
}
